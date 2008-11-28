From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: hardware time stamping with extra skb->hwtstamp
Date: Fri, 28 Nov 2008 14:55:32 +0200
Message-ID: <200811281455.32744.opurdila@ixiacom.com>
References: <1227096528-24150-1-git-send-email-patrick.ohly@intel.com> <200811272053.10009.opurdila@ixiacom.com> <492F1B74.8000701@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Patrick Ohly <patrick.ohly@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:6298 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750755AbYK1NAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 08:00:05 -0500
In-Reply-To: <492F1B74.8000701@hartkopp.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Thu, 27 Nov 2008 23:13:08 +0100

> > How about this twist: we add a new option at the socket level, to get the
> > whole skb->head - skb->end data into a user buffer. Then, we call an
> > device ioctl and pass this buffer. The device will extract the hw
> > timestamp and give it to the user.
> >
> > We might not need to get the whole skb->head - skb->end buffer, maybe
> > just skb->head - skb->mac if we know that skb->mac is sane at the socket 
>> level and we use the convention that the device driver must put the 
>> timestamp below the mac header.
> >
> > One potential problem I see with this approach is leaking sensitive
> > information into userspace, which means we will have to restrict this to
> > privileged processes only.
>
> Ugh.
>
> Not every protocol that uses skbuffs, has a mac header (e.g. the CAN
> protocol doesn't have mac addresses). 

OK, then what about this: we use a device ioctl to get the number of bytes to 
copy from skb->head. We then pass this to the socket level option.

This is more complicated than option 3 or 4, but it should address the 
concerns raised here - no performance impact when not using this feature. The 
trade-off is moving work from core kernel into userspace and device driver. 

> This twist does not look very maintainable to me ...

Could you elaborate on the maintainability issues, they are not clear to me.


Thanks,
tavi


