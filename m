From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v2 net-next 0/8] Introduce bpf ID
Date: Thu, 1 Jun 2017 10:24:00 -0700
Message-ID: <6ab73989-6246-ba15-7178-7863a110165c@fb.com>
References: <cover.1496256722.git.kafai@fb.com>
 <20170531192256.0e0d0ce1@cakuba.lan>
 <3f269312-efd4-86fc-e8e2-814af5898648@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Daniel Borkmann <daniel@iogearbox.net>,
        <kernel-team@fb.com>
To: David Ahern <dsahern@gmail.com>, Jakub Kicinski <kubakici@wp.pl>,
        Martin KaFai Lau <kafai@fb.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:35480 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751089AbdFARYb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 13:24:31 -0400
In-Reply-To: <3f269312-efd4-86fc-e8e2-814af5898648@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/1/17 6:55 AM, David Ahern wrote:
> On 5/31/17 8:22 PM, Jakub Kicinski wrote:
>> On Wed, 31 May 2017 11:58:54 -0700, Martin KaFai Lau wrote:
>>> This patch series:
>>> 1) Introduce ID for both bpf_prog and bpf_map.
>>> 2) Add bpf commands to iterate the prog IDs and map
>>>    IDs of the system.
>>> 3) Add bpf commands to get a prog/map fd from an ID
>>> 4) Add bpf command to get prog/map info from a fd.
>>>    The prog/map info is a jump start in this patchset
>>>    and it is not meant to be a complete list.  They can
>>>    be extended in the future patches.
>>
>> Hi!  IIUC there were plans at some point to store the BPF byte code in
>> the kernel, the way it was loaded from the user space and before it
>> went through the verifier.  Are you still planning on implementing that?
>> It would be handy for offloads to have the original byte code, things
>> like call inlining make translations of maps calls a bit challenging,
>> since we try to run through the verifier again..
>>
>
> Save the instructions:
> https://github.com/dsahern/linux/commit/5315578db7b0886a3e8e3bef6a56e828ae2bd2c4
>
> Let userspace read it back:
> https://github.com/dsahern/linux/commit/619982064b9b582fc5d4a504feffca1730610c4e
>
> One more in between in the branch:
> https://github.com/dsahern/linux/tree/bpf/retrieve-bpf-wip
>
> Now that the id code is in, it needs to be returned on link dumps, route
> dumps, etc and accessible via fdinfo. The id can be turned into an fd
> and the fd read using the above patches.

what problem are we trying to solve?
If we don't agree on the problem, we won't be able to agree on the solution.

Sounds to me that Jakub wants to translate lookup/update helper calls
for JITing and it's difficult due to inlining optimization.
In such case isn't the easiest solution to disable inlining when
JIT to NFP is on?

Dave's case is to be able to retrieve a cgroup_sock program used
for vrf. Such prog doesn't have any maps and I don't see why
returning real insns is not enough.
As Martin said there is work in progress patches that return IDs
for programs attached to everything: cgroup_sock hook, xdp, etc.
The user can get prog ID, convert to FD and dump all insns.
Why this is not enough for VRF introspection?
