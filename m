From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 12/39] wimax: API call to reset a WiMAX device
Date: Tue, 2 Dec 2008 18:05:02 -0800
Message-ID: <200812021805.02645.inaky@linux.intel.com>
References: <cover.1227691434.git.inaky@linux.intel.com> <938311fe52f5b0eb7797fff7c761cc3240c63fe5.1227691434.git.inaky@linux.intel.com> <1227779910.3809.48.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:5961 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753236AbYLCCLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 21:11:30 -0500
In-Reply-To: <1227779910.3809.48.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 27 November 2008, Johannes Berg wrote:
> On Wed, 2008-11-26 at 15:07 -0800, Inaky Perez-Gonzalez wrote:
> > Provides wimax_reset() for the kernel to reset a wimax device as
> > needed.
> >
> > Exports wimax_reset() over generic netlink to user space.
> >
> > +struct genl_ops wimax_gnl_reset = {
> > +	.cmd = WIMAX_GNL_OP_RESET,
> > +	.flags = 0,
>
> permission check again

Fixed

> > +       /* Execute the operation and send the result back to user space
> > */ +       result = wimax_reset(wimax_dev);
> > +       result2 = wimax_gnl_send_rp_result(wimax_dev, info, result);
> > +       if (result2 < 0)
> > +               dev_err(dev, "WIMAX_GNL_RESET: can't send result %d to "
> > +                       "userspace: %d\n", result, result2);
> > +       result = 0;
> > +       dev_put(wimax_dev->net_dev);
> > +error_no_wimax_dev:
> > +error_perm:
> > +       d_fnend(3, NULL, "(skb %p info %p) = %d\n", skb, info, result);
> > +       return result;
>
> This is strange. Can you show your corresponding userspace code? It
> shouldn't be necessary with generic netlink to explicitly send the
> result, if you just return the result from wimax_reset() it'll be part
> of the ACK message and thus already be relayed to userspace. I think
> you're not using genl correctly here.

Fixed

FYI, the user space code is in 
kernel.org/pub/scm/linux/kernel/inaky/wimax-tools.git. However, that's the 
old one that doesn't contain all the fixes I've done with your feedback. 
Still haven't been able to push that one (been a little bit overwhelmed with 
other stuff).

I should be able to push all the changes tomorrow after I finish looking at 
the controller thing.

Thanks,


-- 
Inaky

