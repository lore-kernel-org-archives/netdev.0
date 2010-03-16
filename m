From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: question regarding hw tx csum for IPv6
Date: Tue, 16 Mar 2010 19:44:43 +0000
Message-ID: <1268768683.2091.39.camel@achroite.uk.solarflarecom.com>
References: <20100316091149.GA2680@tuxmaker.boeblingen.de.ibm.com>
	 <1268768246.2091.32.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Blaschka <frank.blaschka@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:21258 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753584Ab0CPTor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 15:44:47 -0400
In-Reply-To: <1268768246.2091.32.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-03-16 at 19:37 +0000, Ben Hutchings wrote:
> On Tue, 2010-03-16 at 10:11 +0100, Blaschka wrote:
> > Hi,
> > 
> > for me it looks like many network drivers exclude IPv6 frames from
> > tx hw csum in case they have extended IPv6 headers. 
> > Does the stack generates the csum for this kind of frames anyhow
> > the device claims to do NETIF_F_HW_CSUM?
> 
> The NETIF_F_*_CSUM flags are for checksum generation, not checksum
> validation.
[...]

Sorry, I misread your question.

NETIF_F_IPV6_CSUM means the device can generate checksums for all
TCP/IPv6 and UDP/IPv6 packets.

NETIF_F_HW_CSUM is different; it means the hardware can generate a
16-bit checksum of the whole packet starting with a given seed value and
place it at a specified offset before transmitting the packet.  The
hardware does not have to parse specific protocols in this case.

If your hardware parses specific protocols then the driver could use
skb_linearize() and the checksum helper functions in the cases that the
hardware doesn't handle.  Then you would still have the benefit of
checksum generation offload in the normal case.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

