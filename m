From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC]  bridge: handle bridge group address per 802.1 standards
Date: Tue, 27 Sep 2011 19:23:05 +0100
Message-ID: <1317147785.2845.39.camel@bwh-desktop>
References: <20110926153630.3959b0ea@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:48959 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883Ab1I0SXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 14:23:09 -0400
In-Reply-To: <20110926153630.3959b0ea@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-09-26 at 15:36 -0700, Stephen Hemminger wrote:
> The Linux bridge code would process all packets addressed to
> the multicast address 01:80:C2:00:00:0X as local and
> and never forward. This may have been correct in the ancient past, but
> reading the relevant standards, the correct behavior is to handle only
> the bridge group address as a special case and leave all other link
> local multicast packets alone.

I disagree.

According to my reading, we must filter at least the addresses ending in
4-D or F, while forwarding of the others should be configurable.

> Recently there has been some complaints about forwarding (or not) of
> 802.1X EAPOL frames by the bridge. Thanks to Tony Jeffree of the 
> 802.1 Bridging Working Group for point me in the correct direction.
> The 802.1X-2010 standard Table 11-1 details how different
> addresses are assigned based on connectivity associations.
>       
>   Bridge group address:		01-80-C2-00-00-00
>   PAE group address:            01-80-C2-00-00-03
>   Link Layer Discovery          01-80-C2-00-00-0E
[...]

This table is informative, non normative.  The text below refers to
802.1D table 7-9 (apparently should be 7-10) and 802.1Q table 8-1 as the
sources.

802.1D-2004 section 7.12.6, Reserved addresses, says:

        Frames containing any of the group MAC Addresses specified in
        Table 7-10 in their destination address field shall not be
        relayed by the Bridge. They are configured in the Permanent
        Database. Management shall not provide the capability to modify
        or remove these entries from the Permanent or the Filtering
        Databases.

In table 7-10 the reserved addresses are those with last digit in the
range 4-F.

802.1Q-2005 section 8.6.3, Frame filtering, says:

        Each of the Reserved MAC Addresses specified in Table 8-1 shall
        be permanently configured in the Filtering Database in
        VLAN-aware Bridges. The Filtering Database Entries for Reserved
        MAC Addresses shall specify filtering for all Bridge Ports and
        all VLANs. Management shall not provide the capability to modify
        or remove entries for Reserved MAC Addresses.

In table 8-1 the reserved addresses are those with last digit in the
range 4-D or F.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
