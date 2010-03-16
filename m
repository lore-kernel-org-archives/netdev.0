From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: question regarding hw tx csum for IPv6
Date: Tue, 16 Mar 2010 19:37:26 +0000
Message-ID: <1268768246.2091.32.camel@achroite.uk.solarflarecom.com>
References: <20100316091149.GA2680@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Blaschka <frank.blaschka@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:20905 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755568Ab0CPTha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 15:37:30 -0400
In-Reply-To: <20100316091149.GA2680@tuxmaker.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-03-16 at 10:11 +0100, Blaschka wrote:
> Hi,
> 
> for me it looks like many network drivers exclude IPv6 frames from
> tx hw csum in case they have extended IPv6 headers. 
> Does the stack generates the csum for this kind of frames anyhow
> the device claims to do NETIF_F_HW_CSUM?

The NETIF_F_*_CSUM flags are for checksum generation, not checksum
validation.  The networking stack does not need to know about the
device's checksum validation capabilities but only needs to know whether
individual skbs have been validated.  If the device reports the
checksum(s) as invalid or if it cannot parse the packet you set
skb->ip_summed = CHECKSUM_NONE and it will be verified in software if
necessary.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

