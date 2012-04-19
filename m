From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 1/4 (V3)] net: ethtool: add the EEE support
Date: Thu, 19 Apr 2012 16:30:01 +0100
Message-ID: <1334849401.2426.73.camel@bwh-desktop.uk.solarflarecom.com>
References: <1333704559-11251-1-git-send-email-peppe.cavallaro@st.com>
	  <1333704559-11251-2-git-send-email-peppe.cavallaro@st.com>
	 <1334269598.2497.50.camel@bwh-desktop.uk.solarflarecom.com>
	 <4F8BB103.7020107@st.com> <4F900C08.5000906@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <rayagond@vayavyalabs.com>,
	<davem@davemloft.net>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:30003 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752796Ab2DSPaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 11:30:05 -0400
In-Reply-To: <4F900C08.5000906@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-19 at 14:58 +0200, Giuseppe CAVALLARO wrote:
> Hello Ben,
> 
> On 4/16/2012 7:41 AM, Giuseppe CAVALLARO wrote:
> [snip]
> >> What I meant is that userland should be able to find out (a), and,
> >> *separately*, either (b) or (c).  That is, there must be at least 2
> >> separate flags for this.  In fact, I explicitly requested you define
> >> supported/advertising/lp_advertising bitmasks for EEE link modes just
> >> like we have for autonegotiation.  But you've made no substantive
> >> changes in response to my review, aside from dropping the added field in
> >> ethtool_cmd.
> > 
> > Sorry Ben but I believed that (c) was enough.
> > 
> >> What you're submitting just isn't good enough for a generic interface,
> >> as the ethtool API is supposed to be.  It's not even a good interface to
> >> your driver.
> > 
> > yes! I'll rework this and provide new patches asap.
> 
> sorry if I disturb you but I want to be sure to avoid to forget
> something else in the next EEE patches (avoiding to continuously disturb
> you).
> 
> I'm changing the code for getting/setting the EEE capability and trying
> to follow your suggestions.
> 
> The "get" will show the following things; this is a bit different of the
> points "a" "b" and "c" we had discussed. Maybe, this could also be a
> more complete (*) .
> The ethtool (see output below as example) could report the phy
> (supported/advertised/lp_advertised) and mac eee capabilities separately.

Sounds reasonable.

> The "set" will be useful for some eth devices (like the stmmac) that can
> stop/enable internally the eee capability (at mac level).

I don't know much about EEE, but shouldn't the driver take care of
configuring the MAC for this whenever the PHY is set to advertise EEE
capability?

> What do you think?
> 
> Regards
> Peppe
> 
> ----
> 
> # ./ethtool  eth0
> Settings for eth0:
> 
> [snip]
> 
> 	Current message level: 0x0000003f (63)
> 			       drv probe link timer ifdown ifup
> 	Link detected: yes
> 	Energy-Efficient Ethernet:           -------------------------
> 		MAC supports: yes            |-> related to MAC side  |
> 		phy supports modes: ...      |-> from MMD 3.20        |
> 		phy advertising modes: ...   |-> from MMD 7.60        |
> 		LP advertising modes: ...    |-> from MMD 7.61        |
> 					     --------------------------
>                                                     (*)
> PS. The "..." above means that we can actually dump: 100BASE-TX EEE etc
> for each advertising modes and also for phy support (reg 3.20).

Yes, that's the sort of information I would expect to see (but try to be
consistent with the wording used for AN).

The EEE advertising mask presumably should be changeable similarly to
the AN advertising mask ('ethtool -s <devname> eeeadv <mask>').  But I
don't know how the two advertising masks interact.  Is one supposed to
be a subset of the other?  Currently ethtool automatically changes the
AN advertising mask in response to a speed/duplex change; should it also
try to change the EEE advertising mask?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
