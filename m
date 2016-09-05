From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH v3 3/6] bpf: add BPF_PROG_ATTACH and BPF_PROG_DETACH
 commands
Date: Mon, 5 Sep 2016 14:56:20 +0200
Message-ID: <4799c1ce-4cb6-0148-26ce-8b6a8ac2a0eb@zonque.org>
References: <1472241532-11682-1-git-send-email-daniel@zonque.org>
 <1472241532-11682-4-git-send-email-daniel@zonque.org>
 <20160827000819.GB29480@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: htejun@fb.com, daniel@iogearbox.net, ast@fb.com,
        davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:56667 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932119AbcIEM4X (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 08:56:23 -0400
In-Reply-To: <20160827000819.GB29480@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/2016 02:08 AM, Alexei Starovoitov wrote:
> On Fri, Aug 26, 2016 at 09:58:49PM +0200, Daniel Mack wrote:

>> +
>> +	struct { /* anonymous struct used by BPF_PROG_ATTACH/DETACH commands */
>> +		__u32		target_fd;	/* container object to attach to */
>> +		__u32		attach_bpf_fd;	/* eBPF program to attach */
>> +		__u32		attach_type;	/* BPF_ATTACH_TYPE_* */
>> +		__u64		attach_flags;
>> +	};
> 
> there is a 4 byte hole in this struct. Can we pack it differently?

Okay - I swapped "type" and "flags" to repair this.

>> +	switch (attr->attach_type) {
>> +	case BPF_ATTACH_TYPE_CGROUP_INET_INGRESS:
>> +	case BPF_ATTACH_TYPE_CGROUP_INET_EGRESS: {
>> +		struct cgroup *cgrp;
>> +
>> +		prog = bpf_prog_get_type(attr->attach_bpf_fd,
>> +					 BPF_PROG_TYPE_CGROUP_SOCKET_FILTER);
>> +		if (IS_ERR(prog))
>> +			return PTR_ERR(prog);
>> +
>> +		cgrp = cgroup_get_from_fd(attr->target_fd);
>> +		if (IS_ERR(cgrp)) {
>> +			bpf_prog_put(prog);
>> +			return PTR_ERR(cgrp);
>> +		}
>> +
>> +		cgroup_bpf_update(cgrp, prog, attr->attach_type);
>> +		cgroup_put(cgrp);
>> +
>> +		break;
>> +	}
> 
> this } formatting style is confusing. The above } looks
> like it matches 'switch () {'.
> May be move 'struct cgroup *cgrp' to the top to avoid that?

I kept it local to its users, but you're right, it's not worth it. Will
change.


Thanks,
Daniel
