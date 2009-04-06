From: Dan Williams <dcbw@redhat.com>
Subject: RE: PATCH_ppp_mp_explode_redesign
Date: Mon, 06 Apr 2009 17:11:16 -0400
Message-ID: <1239052276.28824.26.camel@localhost.localdomain>
References: <49AD1AAB.mail7XX11MN1A@intel.com>
	 <20090313.160929.74391613.davem@davemloft.net>
	 <B53FBD69205CDD4EA91C63A5E0E0BE791F2ECE18@irsmsx502.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"paulus@samba.org" <paulus@samba.org>
To: "Paoloni, Gabriele" <gabriele.paoloni@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36395 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753711AbZDFVJ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Apr 2009 17:09:58 -0400
In-Reply-To: <B53FBD69205CDD4EA91C63A5E0E0BE791F2ECE18@irsmsx502.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-04-06 at 17:38 +0100, Paoloni, Gabriele wrote:
> Hi 
> 
> Can anybody tell me what is the procedure that is followed to apply the patch and when it will be officially released.

Dave Miller (networking maintainer) applied your patch to his various
trees on March 13th.  Since 2.6.29 was in bug-fix only mode at that
time, your patch was too late to be included 2.6.29.  It has just been
merged into Linus' linux-2.6 tree [1] (which will become 2.6.30) via
Dave Miller's tree.  So it appears your patch will be included in the
2.6.30 kernel when that is released.

If you think your patch is regression-free and appropriate for stable
kernels (2.6.27, 2.6.28, etc) you might try to send it to the stable
team for inclusion in subsequent stable kernel updates.

Dan

[1] http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=9c705260feea6ae329bc6b6d5f6d2ef0227eda0a


> Thanks and Regards
> 
> Gabriele Paoloni
> 
> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net] 
> Sent: 13 March 2009 23:09
> To: Paoloni, Gabriele
> Cc: netdev@vger.kernel.org; paulus@samba.org
> Subject: Re: PATCH_ppp_mp_explode_redesign
> 
> From: gabriele.paoloni@intel.com
> Date: Tue, 03 Mar 2009 11:55:23 +0000
> 
> > Problem Solution:
> > 
> > The problem has been solved by redesigning the "ppp_mp_explode" function in such 
> > a way to make it split the sk_buff buffer according to the speeds of the underlying 
> > PPP channels (the speeds of the serial interfaces respectively attached to the PPP 
> > channels). Referring to the above example, the redesigned "ppp_mp_explode" function 
> > will now divide the 1000 Bytes buffer into two fragments whose sizes are set 
> > according to the speeds of the channels where they are going to be sent on (e.g . 
> > 10 Byets on 10KB/sec channel and 990 Bytes on 1000KB/sec channel). 
> > The reworked function grants the same performances of the original one in optimal 
> > working conditions (i.e. a bundle made up of PPP links all working at the same 
> > speed), while greatly improving performances on the bundles made up of channels 
> > working at different speeds.
> 
> Looks good, applied.
> 
> ---------------------------------------------------------------------
> Intel Shannon Limited
> Registered in Ireland
> Registered Office: One Spencer Dock, North Wall Quay, Dublin 1
> Registered Number: 308263
> Business address: Dromore House, East Park, Shannon, Co. Clare
> 
> This e-mail and any attachments may contain confidential material for
> the sole use of the intended recipient(s). Any review or distribution
> by others is strictly prohibited. If you are not the intended
> recipient, please contact the sender and delete all copies.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

