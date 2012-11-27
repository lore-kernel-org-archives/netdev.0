From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: smsc95xx: detect chip revision specific features
Date: Tue, 27 Nov 2012 15:39:57 +0300
Message-ID: <20121127123957.GT6186@mwanda>
References: <20121126204722.GA26463@elgon.mountain>
 <CAKh2mn4x=0HwUdH8hSbk3fsa16RUBqze_n5XegVjRBsTnT08SA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Steve Glendinning <steve@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:31125 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753280Ab2K0MkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 07:40:06 -0500
Content-Disposition: inline
In-Reply-To: <CAKh2mn4x=0HwUdH8hSbk3fsa16RUBqze_n5XegVjRBsTnT08SA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 27, 2012 at 12:32:26PM +0000, Steve Glendinning wrote:
> Hi Dan,
> 
> > drivers/net/usb/smsc95xx.c
> >   1283          if (pdata->wolopts & (WAKE_BCAST | WAKE_MCAST | WAKE_ARP | WAKE_UCAST)) {
> >   1284                  u32 *filter_mask = kzalloc(32, GFP_KERNEL);
> >                                                    ^^
> > We allocate 8 unsigned 32 bit values.  I think this is the mistake here
> > actually.  It is a typo and should say:
> >
> >                         u32 *filter_mask = kzalloc(sizeof(u32) * 32, GFP_KERNEL);
> >
> > If 8 elements was the intent then that's nasty.
> 
> Good spot!  8 32-bit elements was the intent, but all the following
> code is actually accessing it using what should be byte offsets.  So I
> think this should read:
> 
>     u8 *filter_mask = kzalloc(32, GFP_KERNEL);
> 
> The rest of the code following makes sense then, up until:
> 
> >   1349                          ret = smsc95xx_write_reg_nopm(dev, WUFF, filter_mask[i]);
> 
> Which we'll need to change so it dereferences a u32 at that offset
> instead of a u8, something like *((u32 *)&filter_mask[i])
> 
> If this looks good to you I'll prepare a patch?
> 

Sound fine to me.  Could you give me the Reported-by: tag?

regards,
dan carpenter
