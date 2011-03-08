From: Adam Majer <adamm@zombino.com>
Subject: Re: [PATCH] bridge:  control carrier based on ports online
Date: Mon, 7 Mar 2011 19:08:47 -0600
Message-ID: <20110308010847.GA2316@mira.lan.galacticasoftware.com>
References: <1649722795.14144.1299480074110.JavaMail.root@tahiti.vyatta.com>
 <4D748CC3.8060603@gmail.com>
 <20110307103406.27330529@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from polaris.galacticasoftware.com ([216.55.199.131]:48009 "EHLO
	polaris.galacticasoftware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755960Ab1CHBJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 20:09:34 -0500
Content-Disposition: inline
In-Reply-To: <20110307103406.27330529@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 07, 2011 at 10:34:06AM -0800, Stephen Hemminger wrote:
> This makes the bridge device behave like a physical device.
> In earlier releases the bridge always asserted carrier. This
> changes the behavior so that bridge device carrier is on only
> if one or more ports are in the forwarding state. This
> should help IPv6 autoconfiguration, DHCP, and routing daemons.

Yes, your patch does fix issues with IPv6 autoconfiguration in bridged
networks completely. I've just tested it with and without STP. IPv4
DHCP continues to function correctly. It is definitely much cleaner
solution than my hack.

IPv6 autoconfiguration code already checks if NETDEV_CHANGE or
NETDEV_UP represent a device that is ready to transmit data before
attempting to configure the interface. No additional changes required
there. This patch should also fix duplicate address detection of
linklocal address on bridged interfaces that I believe was also broken
prior to this patch.

If you want, you can add

Tested-By: Adam Majer <adamm@zombino.com>


Cheers,
- Adam
