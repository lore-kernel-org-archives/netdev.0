From: "Denys" <denys@visp.net.lb>
Subject: Re: Ethernet weirdness on 82xx
Date: Sun, 2 Sep 2007 14:12:01 +0300
Message-ID: <20070902110957.M44221@visp.net.lb>
References: <DCEAAC0833DD314AB0B58112AD99B93B0353A6AB@ismail.innsys.innovsys.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: "Rune Torgersen" <runet@innovsys.com>,
	<linuxppc-embedded@ozlabs.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 205-177-186-134.btnaccess.net ([205.177.186.134]:32774 "EHLO
	usermail.globalproof.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755248AbXIBLkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2007 07:40:20 -0400
In-Reply-To: <DCEAAC0833DD314AB0B58112AD99B93B0353A6AB@ismail.innsys.innovsys.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thats normal.
Check arp_filter sysctl :
arp_filter - BOOLEAN
        1 - Allows you to have multiple network interfaces on the same
        subnet, and have the ARPs for each interface be answered
        based on whether or not the kernel would route a packet from
        the ARP'd IP out that interface (therefore you must use source
        based routing for this to work). In other words it allows control
        of which cards (usually 1) will respond to an arp request.

        0 - (default) The kernel can respond to arp requests with addresses
        from other interfaces. This may seem wrong but it usually makes
        sense, because it increases the chance of successful communication.
        IP addresses are owned by the complete host on Linux, not by
        particular interfaces. Only for more complex setups like load-
        balancing, does this behaviour cause problems.

        arp_filter for the interface will be enabled if at least one of
        conf/{all,interface}/arp_filter is set to TRUE,
        it will be disabled otherwise

IMHO default setting can mess up things in some conditions.

On Fri, 31 Aug 2007 16:35:19 -0500, Rune Torgersen wrote
> I'm not sure if this is by design or an actual bug.
> 
> We have a system witb an 8280 with two active ethernets (fcc2 and 
> fcc3) We are running kernel 2.6.18.1 (and won't be upgrading in a 
> while) out of arch/ppc
> 
> Eth0 and eth1 are in totally different subnets.
> We happened to have both ehternets connected to the same network,
>  and I ran a arping agains the IP on eth0. Both ports (eth0 and eth1)
>  responded with the same address, but different macs....
> 
> sudo /sbin/arping -c1 172.23.12.114
> ARPING 172.23.12.114 from 172.23.15.21 eth0
> Unicast reply from 172.23.12.114 [00:30:D7:00:14:55]  0.838ms
> Unicast reply from 172.23.12.114 [00:30:D7:00:14:54]  0.890ms
> Sent 1 probes (1 broadcast(s))
> Received 2 response(s)
> 
> It only gets both responses on the first (broadcast) query from 
> arping All responses afterward is then from the wrong port....
> 
> The ethernet setup on the target box:
> 
> eth0      Link encap:Ethernet  HWaddr 00:30:D7:00:14:54
>           inet addr:172.23.12.114  Bcast:172.23.15.255
> Mask:255.255.248.0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:473244 errors:0 dropped:2 overruns:0 frame:0
>           TX packets:186655 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:162928671 (155.3 Mb)  TX bytes:42222862 (40.2 Mb)
>           Base address:0x8500
> 
> eth1      Link encap:Ethernet  HWaddr 00:30:D7:00:14:55
>           inet addr:192.168.0.100  Bcast:192.168.0.255
> Mask:255.255.255.0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:1553 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:4 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:203182 (198.4 Kb)  TX bytes:168 (168.0 b)
>           Base address:0x8600
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

