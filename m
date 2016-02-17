From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v3 3/8] net: sched: add cls_u32 offload hooks
 for netdevs
Date: Wed, 17 Feb 2016 15:07:23 -0800
Message-ID: <56C4FD2B.9000009@gmail.com>
References: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810> <20160217051709.17139.88337.stgit@john-Precision-Tower-5810> <56C4528E.5090505@mojatatu.com> <56C48295.9030806@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, jiri@resnulli.us,
	amir@vadai.me, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35360 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030340AbcBQXHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 18:07:34 -0500
Received: by mail-pf0-f177.google.com with SMTP id c10so19953691pfc.2
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 15:07:34 -0800 (PST)
In-Reply-To: <56C48295.9030806@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>>
>>> +static void u32_replace_hw_hnode(struct tcf_proto *tp, struct
>>> tc_u_hnode *h)
>>> +{
>>> +    struct net_device *dev = tp->q->dev_queue->dev;
>>> +    struct tc_cls_u32_offload u32_offload = {0};
>>> +    struct tc_to_netdev offload;
>>> +
>>> +    offload.type = TC_SETUP_CLSU32;
>>> +    offload.cls_u32 = &u32_offload;
>>> +
>>> +    if (dev->netdev_ops->ndo_setup_tc) {
>>> +        offload.cls_u32->command = TC_CLSU32_NEW_HNODE;
>>
>> TC_CLSU32_REPLACE_HNODE?
>>
> 
> Yep I made this change and will send out v4.
> 
> [...]
> 
>>

Actually thinking about this a bit more I wrote this thinking
that there existed some hardware that actually cared if it was
a new rule or an existing rule. For me it doesn't matter I do
the same thing in the new/replace cases I just write into the
slot on the hardware table and if it happens to have something
in it well its overwritten e.g. "replaced". This works because
the cls_u32 layer protects us from doing something unexpected.

I'm wondering (mostly asking the mlx folks) is there hardware
out there that cares to make this distinction between new and
replace? Otherwise I can just drop new and always use replace.
Or vice versa which is the case in its current form.

Thanks,
John
