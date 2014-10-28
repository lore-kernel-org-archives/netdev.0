From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH v2 01/15] net: dsa: Don't set skb->protocol on outgoing
 tagged packets
Date: Tue, 28 Oct 2014 12:23:05 -0700
Message-ID: <20141028192305.GB12033@roeck-us.net>
References: <1414342365-27191-1-git-send-email-linux@roeck-us.net>
 <1414342365-27191-2-git-send-email-linux@roeck-us.net>
 <544FEC39.4060903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:56681 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbaJ1TXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 15:23:09 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1XjCMG-003QF9-QU
	for netdev@vger.kernel.org; Tue, 28 Oct 2014 19:23:08 +0000
Content-Disposition: inline
In-Reply-To: <544FEC39.4060903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 28, 2014 at 12:19:21PM -0700, Florian Fainelli wrote:
> On 10/26/2014 09:52 AM, Guenter Roeck wrote:
> > Setting skb->protocol to a private protocol type may result in warning
> > messages such as
> > 	e1000e 0000:00:19.0 em1: checksum_partial proto=dada!
> > 
> > This happens if the L3 protocol is IP or IPv6 and skb->ip_summed is set
> > to CHECKSUM_PARTIAL. Looking through the code, it appears that changing
> > skb->protocol for transmitted packets is not necessary and may actually
> > be harmful. Drop it.
> 
> You could emphasize that overriding skb->protocol prevents purposely
> unmodified (from a DSA perspective) network drivers from properly
> setting up their transmit checksum offload pointers since they inspect
> skb->protocol to setup the IPv4 header or IPv6 header pointers.
> 
Ok, I'll do that.

Thanks,
Guenter
