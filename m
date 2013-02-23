From: Adam Baker <linux@baker-net.org.uk>
Subject: Problem with multicast traffic when using network bridging
Date: Sat, 23 Feb 2013 18:18:56 +0000
Message-ID: <51290810.5060205@baker-net.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from april.london.02.net ([87.194.255.143]:51882 "EHLO
	april.london.02.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754437Ab3BWSYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2013 13:24:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After upgrading the kernel on the box that acts as a bridge between my 
wireless and wired networks I observed that access to my UPnP media 
servers became unreliable.

I tried a number of kernel versions to attempt to establish when things 
went wrong and got as far as

3.4 - works
3.5.7 - doesn't work
3.6.11 - doesn't work
3.7.1 - doesn't work
3.7.6 - doesn't work

I can test other versions if required but it doesn't always fail 
instantly and sometimes takes several hours before I notice it has 
failed so don't expect a quick response

All of the above are built with
CONFIG_BRIDGE_IGMP_SNOOPING=y

Knowing that I wasn't having problems with other traffic and the UPnP 
was the only protocol I use that relies on multicast I started looking 
at what changed in the file net/bridge/br_multicast.c and found the patch

bridge: Add multicast_querier toggle and disable queries by default
http://patchwork.ozlabs.org/patch/152295/

so tried

echo 1 >/sys/class/net/br0/bridge/multicast_querier

and after 48 hours of testing running kernel 3.7.6 it seems to be 
working reliably.

Whilst setting that value manually at boot time would be adequate to 
meet my needs it is reasonable to assume that vendors will build 
wireless access points using new kernels that would also exhibit this 
behaviour and users may not be able to get at the internals easily to 
change this configuration.

I therefore suspect that the assumption this patch makes that generating 
queries in the bridge is only an optimisation and isn't necessary isn't 
universally true.

Other details about my network configuration that may be relevant:
There are 2 UPnP media servers, one on the bridge machine and one on a 
machine on the wired network
There are 1 or 2 UPnP media control point / renderers, both on the 
wireless network
As I'm not using multicast on offsite links the IGMP proxy setting is 
disabled on my ADSL router (which is connected to the wired network)

Things I think are irrelevant but I'll mention just in case:
Bridge machine is a Marvell Kirkwood ARM5TE CPU
The wired network includes some homeplug connections

Have I done something unreasonable with my configuration or have I found 
a bug?

Thanks

Adam Baker
