From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v2 net] bpf: introduce BPF_F_ALLOW_OVERRIDE flag
Date: Sat, 11 Feb 2017 21:52:58 -0800
Message-ID: <589FF83A.4010201@fb.com>
References: <1486787304-2805663-1-git-send-email-ast@fb.com>
 <20170212054739.GA13855@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Daniel Mack <daniel@zonque.org>,
        Andy Lutomirski <luto@amacapital.net>, <netdev@vger.kernel.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:46567 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750717AbdBLFx2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 00:53:28 -0500
In-Reply-To: <20170212054739.GA13855@mtj.duckdns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/11/17 9:47 PM, Tejun Heo wrote:
> On Fri, Feb 10, 2017 at 08:28:24PM -0800, Alexei Starovoitov wrote:
>> If BPF_F_ALLOW_OVERRIDE flag is used in BPF_PROG_ATTACH command
>> to the given cgroup the descendent cgroup will be able to override
>> effective bpf program that was inherited from this cgroup.
>> By default it's not passed, therefore override is disallowed.
>>
>> Examples:
>> 1.
>> prog X attached to /A with default
>> prog Y fails to attach to /A/B and /A/B/C
>> Everything under /A runs prog X
>>
>> 2.
>> prog X attached to /A with allow_override.
>> prog Y fails to attach to /A/B with default (non-override)
>> prog M attached to /A/B with allow_override.
>> Everything under /A/B runs prog M only.
>>
>> 3.
>> prog X attached to /A with allow_override.
>> prog Y fails to attach to /A with default.
>> The user has to detach first to switch the mode.
>>
>> In the future this behavior may be extended with a chain of
>> non-overridable programs.
>>
>> Also fix the bug where detach from cgroup where nothing is attached
>> was not throwing error. Return ENOENT in such case.
>>
>> Add several testcases and adjust libbpf.
>>
>> Fixes: 3007098494be ("cgroup: add support for eBPF programs")
>> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
>
> The cgroup part looks good to me.  Please feel free to add
>
> Acked-by: Tejun Heo <tj@kernel.org>
>
> One question tho.  Is there a specific reason to disallow attaching
> !overridable program under an overridable one?  Isn't disallowing
> attaching programs if the closest ancestor is !overridable enough?

yes. I felt the same way and v1 patch did that, but
as Andy pointed out the more strict rules will be easier to
extend later, so this v2 patch is using this approach.

Andy, ping !
