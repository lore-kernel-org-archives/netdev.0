From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2] tc: add BPF based action
Date: Wed, 14 Jan 2015 10:09:10 +0100
Message-ID: <20150114090910.GA1869@nanopsycho.orion>
References: <1421078978-10904-1-git-send-email-jiri@resnulli.us>
 <20150113.143633.1852338751965729543.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, dborkman@redhat.com,
	ast@plumgrid.com, hannes@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:59470 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbbANJJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 04:09:13 -0500
Received: by mail-wg0-f53.google.com with SMTP id x13so7595547wgg.12
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 01:09:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150113.143633.1852338751965729543.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jan 13, 2015 at 08:36:33PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Mon, 12 Jan 2015 17:09:38 +0100
>
>> +	bpf_len = nla_get_u16(tb[TCA_ACT_BPF_OPS_LEN]);
>> +	if (bpf_len > BPF_MAXINSNS || bpf_len == 0)
>> +		return -EINVAL;
>> +
>> +	bpf_size = bpf_len * sizeof(*bpf_ops);
>
>When I see variables named 'len' and 'size', I expect them to be
>in unit bytes.

Size is bytes, len is number of instructions. This is the same as in
net/sched/cls_bpf.c line 182. I follow the same naming for consistency

>
>I think it's clearer to call bpf_len something like "bpf_num_insns",
>or "bpf_num_ops", or something like that.

I understand. I will change it in net/sched/cls_bpf.c as well.

>
>Also, is the OPS_LEN attribute really necessary?  Can't you just
>figure this out using nla_len() on the OPS attribute?  Or is that not
>always accurate due to alignment?

I guess that you could just use nla_len. Again, I followed cls_bpf for
consistency purposes. It has TCA_BPF_OPS_LEN as well.

Thanks for review!

Jiri
