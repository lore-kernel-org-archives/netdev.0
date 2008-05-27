From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: GVRP
Date: Tue, 27 May 2008 19:39:06 +0300 (EEST)
Message-ID: <alpine.LRH.1.10.0805271936140.13277@netcore.fi>
References: <483C328B.7040007@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:59132 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755647AbYE0QjP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 12:39:15 -0400
In-Reply-To: <483C328B.7040007@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 May 2008, Patrick McHardy wrote:
> I've written an applicant-only GVRP implementation for the kernel
> some time ago (for those not familiar: it dynamically registers
> VLANs with switches. Applicant-only means its only the "client-side")
> and I'm wondering whether I should merge it. It should be quite
> easy to move it to userspace, OTOH I think it would be nice to
> have the client-side support for this without having to install
> additional daemons. But since this is not a really strong argument,
> I'd like to hear if anyone has an opinion about this.
>
> The GVRP implementation sits on top of an GARP implementation,
> which could also support GMRP for multicast address registrations.
>
> I'm not including the patch yet because it would need to be
> split up and needs some minor cleanups, just for orientation, the
> GARP implementation is about 600 lines of simple code, the GVRP
> implementation something like 60 lines of even simpler code.

If it's simple, why not?

But-- when I was writing RFC 5110 one of the things we evaluated was 
whether an another application of GARP, GMRP, could be used.

We asked IEEE about this and they said that GARP and GMRP are 
obsolete, below is the most important part of RFC 5110 with this 
respect:

    IEEE 802.1D-2004 specification describes Generic Attribute
    Registration Protocol (GARP), and GARP Multicast Registration
    Protocol (GMRP) [GMRP] is a link-layer multicast group application of
    GARP that notifies switches about MAC multicast group memberships.
    If GMRP is used in conjunction with IP multicast, then the GMRP
    registration function would become associated with an IGMP "join".
    However, this GMRP-IGMP association is beyond the scope of GMRP.
    GMRP requires support at the host stack and it has not been widely
    implemented.  Further, IEEE 802.1 considers GARP and GMRP obsolete
    being replaced by Multiple Registration Protocol (MRP) and Multicast
    Multiple Registration Protocol (MMRP) that are being specified in
    IEEE 802.1ak [802.1ak].  MMRP is expected to be mainly used between
    bridges.  Some further information about GARP/GMRP is also available
    in Appendix B of [RFC3488].

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
