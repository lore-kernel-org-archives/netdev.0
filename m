From: Patrick McHardy <kaber@trash.net>
Subject: Re: [LARTC] Adding qdiscs crashes kernel??
Date: Wed, 05 Dec 2007 09:07:55 +0100
Message-ID: <47565C5B.2030302@trash.net>
References: <96CF49BD8B56384395D698BA99007FA32DB9@exchange.pacwire.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lartc@mailman.ds9a.nl, Linux Netdev List <netdev@vger.kernel.org>
To: Leigh Sharpe <lsharpe@pacificwireless.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55012 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296AbXLEIII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 03:08:08 -0500
In-Reply-To: <96CF49BD8B56384395D698BA99007FA32DB9@exchange.pacwire.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please always report bugs to netdev@vger.kernel.org.

Leigh Sharpe wrote:
> Oh, 
> kernel version 2.6.23, since I forgot to mention it.
>  
> Leigh.
> 
> ________________________________
> 
> From: lartc-bounces@mailman.ds9a.nl
> [mailto:lartc-bounces@mailman.ds9a.nl] On Behalf Of Leigh Sharpe
> Sent: Wednesday, 5 December 2007 3:37 PM
> To: lartc@mailman.ds9a.nl
> Subject: [LARTC] Adding qdiscs crashes kernel??
> 
> 
> Hi all,
>  I'm having some problems setting up qdiscs on a bridge.The config looks
> a little like this:
>  
>  
> ifconfig ifb0 up        # Bring up the IFB for this bridge.
> tc qdisc add dev eth2 ingress
> tc qdisc add dev eth3 ingress
> tc qdisc add dev ifb0 root handle 1:0 cbq bandwidth 100Mbit avpkt 1000
> cell 8
> # Raw qdiscs on each bridge port
> tc qdisc add dev eth2 root handle 1:0 cbq bandwidth 100Mbit avpkt 1000
> cell 8
> tc qdisc add dev eth3 root handle 1:0 cbq bandwidth 100Mbit avpkt 1000
> cell 8
> 
> tc filter add dev eth2 parent 1: protocol 0x8100 prio 5 u32 match u16
> 3000 0x0fff at 0 flowid 1:1 action ipt -j MARK --or-mark 0x01000000 #
> mark packets for VLAN 3000.
> tc filter add dev eth3 parent 1: protocol 0x8100 prio 5 u32 match u16
> 3000 0x0fff at 0 flowid 1:1 action ipt -j MARK --or-mark 0x01000000 #
> mark packets for VLAN 3000.
>  
> tc class add dev eth2 parent 1:0 classid 1:1 cbq bandwidth 100Mbit rate
> 2000Kbit weight 200Kbit prio 1 allot 1514 cell 8 maxburst 20 avpkt 1000
> bounded isolated       # 2000 Kbit rate limit on entry point.
> tc class add dev eth3 parent 1:0 classid 1:1 cbq bandwidth 100Mbit rate
> 2000Kbit weight 200Kbit prio 1 allot 1514 cell 8 maxburst 20 avpkt 1000
> bounded isolated       # 2000 Kbit rate limit on entry point.
> 
> tc qdisc add dev eth2 parent 1:1 handle 2: cbq bandwidth 100Mbit  avpkt
> 1000 cell 8
> tc qdisc add dev eth3 parent 1:1 handle 2: cbq bandwidth 100Mbit  avpkt
> 1000 cell 8
> tc class add dev eth2 parent 2:0 classid 2:1 cbq bandwidth 100Mbit rate
> 2000Kbit weight 200Kbit prio 2 allot 1514 cell 8 maxburst 20 avpkt 1000
> sharing
> tc filter add dev eth2 parent 2:0 protocol 0x8100 prio 2 u32 match u16
> 3000 0x0fff at 0 flowid 2:1 action ipt -j MARK --or-mark 0x00100000 
> tc qdisc add dev eth2 parent 2:1 handle 3: cbq bandwidth 100Mbit avpkt
> 1000 cell 8    
> tc filter add dev eth2 parent 3:0 protocol 0x8100 prio 4 u32 match u32 0
> 0 flowid 3:3                                                   # Traffic
> class 3 - catchall. Don't MARK further.
>  
> (There's lot's more, mostly a repeat of the above with different
> criteria.)
> When I first boot the box, and apply the traffic shaping before any
> traffic flows, all is fine. However, if I apply this same config whilst
> the bridge is passing lots of traffic, it completely crashes the box.
> Everything freezes, I don't even get a kernel panic message on the
> console. Nothing responds and the only way to recover is by a
> power-cycle.
>  
> If I take the link down on the ethernet port (with ip link set ethx
> down), apply the configs, and then bring it back up again, all is OK.
> Obviously, though, this isn't really acceptable.
>  
> It always crashes immediately after a 'tc qdisc add...' line, but not
> always in the same place. Are there any known issues with adding qdiscs
> whilst traffic is being queued on it?
> I've also tried it using HTB instead of CBQ, and I get the same results.
>  
> Anybody got any other ideas as to what might be going on?


Which qdisc add crashes it? Please post the full oops.

