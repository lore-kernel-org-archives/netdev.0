From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC][PATCH 1/2] net: support for TX timestamps
Date: Wed, 30 Jul 2008 16:15:52 +0300
Message-ID: <200807301615.52953.opurdila@ixiacom.com>
References: <1217291753-5322-1-git-send-email-opurdila@ixiacom.com> <1217291753-5322-2-git-send-email-opurdila@ixiacom.com> <1217421813.30512.169.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:23399 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750767AbYG3NSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 09:18:23 -0400
In-Reply-To: <1217421813.30512.169.camel@ecld0pohly>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 30 July 2008, Patrick Ohly wrote:

> > The actual timestamp will reach userspace as a RX timestamp on the
> > cloned packet. If timestamping is requested and no timestamping is
> > done in the device driver (potentially this may use hardware
> > timestamping), it will be done in software after the device's
> > start_hard_xmit routine.
>
> This needs to be augmented to not fall back to software time stamping,
> as discussed in "[RFC][PATCH 1/1] net: support for hardware
> timestamping".
>

Ok, I'll keep this in mind for the next take.

> How do you recognize whether the driver did hardware time stamping? Hmm,
> okay, I think I can answer that myself: if the driver supports hardware
> time stamping, it must clear tstamp in its hard_start_xmit(). Later on
> when it has transmitted the packet, it extracts the corresponding
> hardware time stamp and calls skb_tx_timestamp(). Right? If so, this
> should go into a comment somewhere.
>

Right. 

> The implicit assumption here is that drivers do not touch tstamp,
> because otherwise software time stamping might accidentally be disabled
> by a driver. That seems to be the case, at least for in-kernel drivers.
>

Yes, that is the assumption and I think it should be reasonable.

> Is skb->sk always guaranteed to be set in hard_start_xmit?
> skb_tx_timestamp() depends on it. In 2.6.23 the field always seemed to
> be valid, but in 2.6.26 I think I have seen NULL pointers there for PTP
> UDP broadcasts.

I don't think that skb->sk is guaranteed to be around in hard_start_xmit. But 
we should not need it, if we overload the skb->tstamp, right?

Thanks,
tavi




