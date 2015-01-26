From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH v3 net-next] net: ipv6: Add sysctl entry to disable MTU
 updates from RA
Date: Mon, 26 Jan 2015 09:03:48 -0600
Message-ID: <1422284628.2393.4.camel@dcbw.local>
References: <1421773565-5181-1-git-send-email-harouth@codeaurora.org>
	 <20150124.231432.1788575004982971514.davem@davemloft.net>
	 <20150125072101.GA25495@angus-think.lan> <54C519B3.9050905@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Vadim Kochan <vadim4j@gmail.com>
To: Harout Hedeshian <harouth@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58795 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755418AbbAZPD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2015 10:03:56 -0500
In-Reply-To: <54C519B3.9050905@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-01-25 at 09:28 -0700, Harout Hedeshian wrote:
> On 01/25/2015 12:21 AM, Vadim Kochan wrote:
> > On Sat, Jan 24, 2015 at 11:14:32PM -0800, David Miller wrote:
> >> From: Harout Hedeshian <harouth@codeaurora.org>
> >> Date: Tue, 20 Jan 2015 10:06:05 -0700
> >>
> >>> The kernel forcefully applies MTU values received in router
> >>> advertisements provided the new MTU is less than the current. This
> >>> behavior is undesirable when the user space is managing the MTU.
> > Instead
> >>> a sysctl flag 'accept_ra_mtu' is introduced such that the user space
> >>> can control whether or not RA provided MTU updates should be applied.
> > The
> >>> default behavior is unchanged; user space must explicitly set this
> > flag
> >>> to 0 for RA MTUs to be ignored.
> >>>
> >>> Signed-off-by: Harout Hedeshian <harouth@codeaurora.org>
> >> Under what circumstances would userland ignore a router advertized
> >> MTU, and are the RFCs ok with this?
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe netdev" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Hi,
> >
> > I don't know if it make sense but I had the same use case when was
> > working on supporting IPv6 infrastructure for home gateway.
> > One of the provider had requirements to have ability set force IPv6 MTU
> > value via TR parameters and disable update it via RA.
> Hi David,
> 
> We are optionally allowing the kernel shift this responsibility to the 
> userland. The idea would be that the kernel would ignore it, not so much 
> the userland. Just like Vadim, we may not want to use the MTU value 
> which comes from the network. Instead, we get an MTU value from the 
> cellular modem via configuration message, and that is the MTU we use.

Are you talking about an ethernet interface exposed by the modem, or a
separate network interface connected to a normal LAN?  In the modem
case, why would the network-provided RA's MTU be incorrect, but the
modem's MTU be correct?  If the normal LAN case, why would the modem's
MTU be correct for a different network that is broadcasting its own RAs?
Just curious...

Dan

> In any case, none of the RFCs state that the kernel must update the MTU 
> and that the userland cannot. In fact, there is no mention of 
> kernel/user space at all in the RFC for this particular RA message. What 
> if someone wants to listen to these RA messages from userland and update 
> the MTU? Surely, that won't violate the RFC. In such a case, the kernel 
> is unnecessarily forcing policy on the user space.
> 
> RFC4861 section 4.6.4 defines the MTU update option (RA option 5) for RA 
> messages. I don't see any language where the receiver "MUST" apply this 
> option. It merely states that the MTU value in the RA is "The 
> recommended MTU for the link." The description goes on to point out why 
> this option can be used by the router, but does not specifically enforce 
> it. The only receive action specifically enforced by the RFC is that 
> "This option MUST be silently ignored for other Neighbor Discovery 
> messages."
> 
> The risk of not applying the MTU updates is that packet may get dropped 
> if path MTU discovery is disabled or broken on the network. HOWEVER, 
> anyone explicitly setting accept_ra_mtu to 0 is already taking 
> responsibility for enforcing the correct MTU. Since this patch by 
> default does not change the kernel behavior, I don't see it breaking for 
> users who are unaware of this option.
> 
> 
> Thanks,
> Harout
> 
> --
> Employee of Qualcomm Innovation Center, Inc.
> Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
