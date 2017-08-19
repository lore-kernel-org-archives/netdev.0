From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 1/2] bpf: improve htab inlining for future 32 bit
 jits
Date: Fri, 18 Aug 2017 17:00:57 -0700
Message-ID: <43a2b95f-db1d-8c33-a7d6-42f8299ddcb3@fb.com>
References: <cover.1503100047.git.daniel@iogearbox.net>
 <a2a1360af1df20e5a11269441656b5daffabdd77.1503100047.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:51170 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751586AbdHSAB1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 20:01:27 -0400
In-Reply-To: <a2a1360af1df20e5a11269441656b5daffabdd77.1503100047.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/18/17 4:51 PM, Daniel Borkmann wrote:
> Lets future proof htab lookup inlining, commit 9015d2f59535 ("bpf:
> inline htab_map_lookup_elem()") was making the assumption that a
> direct call emission to __htab_map_lookup_elem() will always work
> out for JITs. This is currently true since all JITs we have are
> for 64 bit archs, but in case of 32 bit JITs like upcoming arm32,
> we get a NULL pointer dereference when executing the call to
> __htab_map_lookup_elem() since passed arguments are of a different
> size (unsigned long vs. u64 for pointers) than what we do out of
> BPF. Thus, lets do a proper BPF_CALL_2() declaration such that we
> don't need to make any such assumptions.
>
> Reported-by: Shubham Bansal <illusionist.neo@gmail.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

assuming on 64-bit archs the should be no perf difference
and only increase in .text, since __htab_map_lookup_elem
is now force inlined into a bunch of places?
I guess that's ok, but kinda sux for 64-bit archs to pay
such penalty because of 32-bit archs.
May be drop always_inline and do such thing conditionally
on 32-bit archs only?
what's the increase in .text?
any difference seen in map_perf_test?
