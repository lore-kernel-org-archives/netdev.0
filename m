From: "Amir Vadai\"" <amir@vadai.me>
Subject: Re: [net-next PATCH v3 3/8] net: sched: add cls_u32 offload hooks
 for netdevs
Date: Thu, 18 Feb 2016 11:23:35 +0200
Message-ID: <20160218092335.GA15192@office.Home>
References: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810>
 <20160217051709.17139.88337.stgit@john-Precision-Tower-5810>
 <56C4528E.5090505@mojatatu.com>
 <56C48295.9030806@gmail.com>
 <56C4FD2B.9000009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, jiri@resnulli.us,
	davem@davemloft.net, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:33424 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1425290AbcBRJUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 04:20:00 -0500
Received: by mail-wm0-f51.google.com with SMTP id g62so15941181wme.0
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 01:20:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56C4FD2B.9000009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 17, 2016 at 03:07:23PM -0800, John Fastabend wrote:
> [...]
> 
> >>
> >>> +static void u32_replace_hw_hnode(struct tcf_proto *tp, struct
> >>> tc_u_hnode *h)
> >>> +{
> >>> +    struct net_device *dev = tp->q->dev_queue->dev;
> >>> +    struct tc_cls_u32_offload u32_offload = {0};
> >>> +    struct tc_to_netdev offload;
> >>> +
> >>> +    offload.type = TC_SETUP_CLSU32;
> >>> +    offload.cls_u32 = &u32_offload;
> >>> +
> >>> +    if (dev->netdev_ops->ndo_setup_tc) {
> >>> +        offload.cls_u32->command = TC_CLSU32_NEW_HNODE;
> >>
> >> TC_CLSU32_REPLACE_HNODE?
> >>
> > 
> > Yep I made this change and will send out v4.
> > 
> > [...]
> > 
> >>
> 
> Actually thinking about this a bit more I wrote this thinking
> that there existed some hardware that actually cared if it was
> a new rule or an existing rule. For me it doesn't matter I do
> the same thing in the new/replace cases I just write into the
> slot on the hardware table and if it happens to have something
> in it well its overwritten e.g. "replaced". This works because
> the cls_u32 layer protects us from doing something unexpected.
> 
> I'm wondering (mostly asking the mlx folks) is there hardware
> out there that cares to make this distinction between new and
> replace? Otherwise I can just drop new and always use replace.
> Or vice versa which is the case in its current form.
I don't see a need for such a distinction in mlx hardware.

Thanks,
Amir.

> 
> Thanks,
> John
> 
