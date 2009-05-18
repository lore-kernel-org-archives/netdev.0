From: Vladimir Ivashchenko <hazard@francoudi.com>
Subject: Re: HTB accuracy for high speed
Date: Tue, 19 May 2009 02:14:39 +0300
Message-ID: <1242688479.9558.60.camel@hazard2.francoudi.com>
References: <298f5c050905150745p13dc226eia1ff50ffa8c4b300@mail.gmail.com>
	 <298f5c050905150749s3597328dr8dd15adbd7a37532@mail.gmail.com>
	 <20090516141430.GB3013@ami.dom.local>
	 <298f5c050905180736m303f0c79ha30d3f791222fa1b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	devik@cdi.cz, Antonio Almeida <vexwek@gmail.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.thunderworx.net ([217.27.32.18]:1366 "EHLO
	cerber.thunderworx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbZERXOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 19:14:51 -0400
In-Reply-To: <298f5c050905180736m303f0c79ha30d3f791222fa1b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-05-18 at 15:36 +0100, Antonio Almeida wrote:
> This patch works perfectly!
> rate (bits/s) is now decreasing along with pps when I stop the traffic
> (doesn't grow as it used to for rates over 500Mbtis/s).

I'm not able to reach full speed with bond + HTB + sfq on 2.6.29.1, both
with and without these patches. I seem to get a lot of drops on sfq
qdiscs, whatever quantum I set. Playing with IRQ affinity doesn't help.
I didn't check without bond.

With bond + HFSC + sfq, I'm able to reach the speed. It doesn't seem to
overspill with 580 mbps load. Jarek, would your patches help with HSFC
overspill ? I will check tomorrow under 750 mbps load. 

# ethtool -k eth0
Offload parameters for eth0:
Cannot get device flags: Operation not supported
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: off
large receive offload: off

# cat /sys/devices/system/clocksource/clocksource0/current_clocksource
tsc

-- 
Best Regards,
Vladimir Ivashchenko
Chief Technology Officer
PrimeTel PLC, Cyprus - www.prime-tel.com
Tel: +357 25 100100 Fax: +357 2210 2211


