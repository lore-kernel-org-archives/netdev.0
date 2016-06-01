From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [RFC 02/12] net: cls_bpf: add hardware offload
Date: Wed, 1 Jun 2016 21:59:47 +0100
Message-ID: <20160601215947.23820510@jkicinski-Precision-T1700>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
	<1464799814-4453-3-git-send-email-jakub.kicinski@netronome.com>
	<574F17CC.8020704@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
	dinan.gunawardena@netronome.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:33991 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbcFAU74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 16:59:56 -0400
Received: by mail-wm0-f54.google.com with SMTP id z87so309666wmh.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 13:59:55 -0700 (PDT)
In-Reply-To: <574F17CC.8020704@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Jun 2016 10:13:48 -0700, John Fastabend wrote:
> > +static void cls_bpf_stop_offload(struct tcf_proto *tp,
> > +				 struct cls_bpf_prog *prog)
> > +{
> > +	struct net_device *dev = tp->q->dev_queue->dev;
> > +
> > +	if (!prog->offloaded)
> > +		return;
> > +	if (WARN_ON(!tc_should_offload(dev, 0)))
> > +		return;  
> 
> This warn on is a bit concerning it looks like you can get
> a program stuck in hardware but removed from the software
> stack. Any idea why this could happen? I think it is better
> to solve the root problem or just remove this if its dbg code.
> 
> One thought is you need to block disabling the ethtool flag
> if the hardware has running ebpf codes. Haven't got to the
> driver patches yet though so not sure if you did this or not.
> And now that I think about it I better go check the other
> drivers.

Yes, I do refuse clearing the ethtool flag if offload is active.
I put the warning there in an attempt to document that "this should
never happen".  I'll drop it in the next revision.
