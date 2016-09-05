From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH v3 1/6] bpf: add new prog type for cgroup socket filtering
Date: Mon, 5 Sep 2016 14:48:15 +0200
Message-ID: <f3a9d9d0-f025-21e7-9ac5-6452427aca7f@zonque.org>
References: <1472241532-11682-1-git-send-email-daniel@zonque.org>
 <1472241532-11682-2-git-send-email-daniel@zonque.org>
 <57C4B3D6.9090000@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me
To: Daniel Borkmann <daniel@iogearbox.net>, htejun@fb.com, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:56597 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932274AbcIEMs2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 08:48:28 -0400
In-Reply-To: <57C4B3D6.9090000@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/30/2016 12:14 AM, Daniel Borkmann wrote:
> On 08/26/2016 09:58 PM, Daniel Mack wrote:
>> For now, this program type is equivalent to BPF_PROG_TYPE_SOCKET_FILTER in
>> terms of checks during the verification process. It may access the skb as
>> well.
>>
>> Programs of this type will be attached to cgroups for network filtering
>> and accounting.
>>
>> Signed-off-by: Daniel Mack <daniel@zonque.org>
>> ---
>>   include/uapi/linux/bpf.h | 7 +++++++
>>   kernel/bpf/verifier.c    | 1 +
>>   net/core/filter.c        | 6 ++++++
>>   3 files changed, 14 insertions(+)
>>
>> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
>> index e4c5a1b..1d5db42 100644
>> --- a/include/uapi/linux/bpf.h
>> +++ b/include/uapi/linux/bpf.h
>> @@ -95,6 +95,13 @@ enum bpf_prog_type {
>>   	BPF_PROG_TYPE_SCHED_ACT,
>>   	BPF_PROG_TYPE_TRACEPOINT,
>>   	BPF_PROG_TYPE_XDP,
>> +	BPF_PROG_TYPE_CGROUP_SOCKET_FILTER,
>> +};
> 
> Nit: can we drop the _FILTER suffix? So just leaving it
> at BPF_PROG_TYPE_CGROUP_SOCKET. Some of these use cases
> might not always strictly be related to filtering, so
> seems cleaner to just leave it out everywhere.
> 
>> +
>> +enum bpf_attach_type {
>> +	BPF_ATTACH_TYPE_CGROUP_INET_INGRESS,
>> +	BPF_ATTACH_TYPE_CGROUP_INET_EGRESS,
>> +	__MAX_BPF_ATTACH_TYPE
>>   };
> 
> #define BPF_MAX_ATTACH_TYPE	__BPF_MAX_ATTACH_TYPE
> 
> And then use that in your follow-up patches for declaring
> arrays, etc?

Agreed, will change.


Thanks,
Daniel
