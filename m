From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next v2 1/2] bpf: make htab inlining more robust wrt
 assumptions
Date: Fri, 18 Aug 2017 18:20:24 -0700
Message-ID: <b005c1b5-12c9-3477-b4e9-49798ac0e0ba@fb.com>
References: <cover.1503104831.git.daniel@iogearbox.net>
 <03f4e86a029058d0f674fd9bf288e55a5ec07df3.1503104831.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:36515 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751054AbdHSBUu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 21:20:50 -0400
In-Reply-To: <03f4e86a029058d0f674fd9bf288e55a5ec07df3.1503104831.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/18/17 6:12 PM, Daniel Borkmann wrote:
> Commit 9015d2f59535 ("bpf: inline htab_map_lookup_elem()") was
> making the assumption that a direct call emission to the function
> __htab_map_lookup_elem() will always work out for JITs.
>
> This is currently true since all JITs we have are for 64 bit archs,
> but in case of 32 bit JITs like upcoming arm32, we get a NULL pointer
> dereference when executing the call to __htab_map_lookup_elem()
> since passed arguments are of a different size (due to pointer args)
> than what we do out of BPF. Guard and thus limit this for now for
> the current 64 bit JITs only.
>
> Reported-by: Shubham Bansal <illusionist.neo@gmail.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@kernel.org>
Thanks. That's good robustness fix.
