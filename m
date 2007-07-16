From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: Re: IPSec freeze
Date: Mon, 16 Jul 2007 10:27:56 +0200
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD1323022E@exch.facton.local>
References: <3C59DB883F7B0B4D8096010D45ACCD13230225@exch.facton.local> <469A3698.5020105@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:32786 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753844AbXGPI2F convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 04:28:05 -0400
Content-class: urn:content-classes:message
In-reply-to: <469A3698.5020105@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Beschorner Daniel wrote:
> > Today a new site joined our Linux IPSec VPN, now all the 
> other routers
> > (all 2.6.22) freeze hard reproducible.
> 
> Do the other routers all do IPsec or just one of them?

They all do IPSec, that seems to be their mistake.
The unencrypted traffic between the routers work fine, only tunnel
traffic triggers the crash.

> 
> > No oops, no sysreq, only hard reset rewakes them.
> 
> > 
> > The only difference of the new site compared to the others: 
> ADSL, thus a
> > MTU of 1492, the others have 1500.
> > Disabling IPSec und doing normal operations between the 
> routers is fine,
> > PMTU is honored correctly.
> > If I set the MTU of the other routers to 1492 I can avoid the IPSec
> > crash.
> > 
> > Some kind of strange need-to-frag-ICMP that causes such things?
> > Any ideas how to debug this?
> 
> 
> If you can't get any information from your boxes, a testcase that can
> be used to reproduce this would help.

I'll try to get more information about what is the fatal in this
configuration.
I'm surely not the first one doing VPN with different MTUs.

The only "anomaly" I've seen is that the need-to-frag complaining router
DOES fragment the oversized packet and relays it ignoring the DF flag.

Is there something I can do to debug the network stack in any way? As I
said, I can perfectly reproduce it, but I'm poor in getting information
what's going on in the kernel.

I will do some more tests, disabling Ipsec compression, etc.

> 
> > Here a log of another death from inside the tunnel (last 
> packet is again
> > the time of crash):
> > The Tunnel MTU of 1430 is correct for an outer MTU of 1500, but the
> > additional -8 doesn't take place?!?
> > 
> > 05:17:18.563448 IP 192.168.200.1.80 > 192.168.203.1.3084: tcp 1460
> > 05:17:18.563468 IP 192.168.200.254 > 192.168.200.1: ICMP 
> 192.168.203.1
> > unreachable - need to frag (mtu 1430), length 556
> 
> 
> Does the router use a MTU of 1492 itself or is there another DSL
> router or something like that connected by ethernet?

The router on the ADSL line (behind an ADSL Netopia router via Ethernet)
crashed too with 1500, now it uses 1492.
