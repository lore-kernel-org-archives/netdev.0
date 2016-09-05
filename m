From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH v3 3/6] bpf: add BPF_PROG_ATTACH and BPF_PROG_DETACH
 commands
Date: Mon, 5 Sep 2016 14:54:00 +0200
Message-ID: <9894ace9-06f7-4c41-e8fe-6047adad740e@zonque.org>
References: <1472241532-11682-1-git-send-email-daniel@zonque.org>
 <1472241532-11682-4-git-send-email-daniel@zonque.org>
 <57C4BE77.8070309@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me
To: Daniel Borkmann <daniel@iogearbox.net>, htejun@fb.com, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:56653 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932119AbcIEMzM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 08:55:12 -0400
In-Reply-To: <57C4BE77.8070309@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/30/2016 01:00 AM, Daniel Borkmann wrote:
> On 08/26/2016 09:58 PM, Daniel Mack wrote:

>>   enum bpf_map_type {
>> @@ -147,6 +149,13 @@ union bpf_attr {
>>   		__aligned_u64	pathname;
>>   		__u32		bpf_fd;
>>   	};
>> +
>> +	struct { /* anonymous struct used by BPF_PROG_ATTACH/DETACH commands */
>> +		__u32		target_fd;	/* container object to attach to */
>> +		__u32		attach_bpf_fd;	/* eBPF program to attach */
>> +		__u32		attach_type;	/* BPF_ATTACH_TYPE_* */
>> +		__u64		attach_flags;
> 
> Could we just do ...
> 
> __u32 dst_fd;
> __u32 src_fd;
> __u32 attach_type;
> 
> ... and leave flags out, since unused anyway? Also see below.

I'd really like to keep the flags, even if they're unused right now.
This only adds 8 bytes during the syscall operation, so it doesn't harm.
However, we cannot change the userspace API after the fact, and who
knows what this (rather generic) interface will be used for later on.

> #define BPF_PROG_ATTACH_LAST_FIELD attach_type
> #define BPF_PROG_DETACH_LAST_FIELD BPF_PROG_ATTACH_LAST_FIELD

...

> 
> Correct way would be to:
> 
> 	if (CHECK_ATTR(BPF_PROG_ATTACH))
> 		return -EINVAL;

Will add - thanks!


Daniel
