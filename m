From: Tore Anderson <tore.anderson@redpill-linpro.com>
Subject: Re: "NIG timer max" messages from bnx2x
Date: Thu, 03 Dec 2009 08:36:38 +0100
Message-ID: <4B176A86.30009@redpill-linpro.com>
References: <4B168F04.60309@redpill-linpro.com> <1259779263.2020.6.camel@lb-tlvb-eilong>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Benjamin Li <benli@broadcom.com>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.linpro.no ([87.238.49.141]:45800 "EHLO
	mailhub.linpro.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643AbZLCHgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 02:36:41 -0500
In-Reply-To: <1259779263.2020.6.camel@lb-tlvb-eilong>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eilon Greenstein

> This message indicates that for over 1 second, the device could not 
> transmit anything to the network (the same packet was not
> transmitted for over one second) - this usually happens when the
> network is in fatal condition - usually because some device is
> sending constant pause stream that halts all traffic. In this case,
> the device is incrementing the counter and drains outgoing traffic -
> without this action, the device will not be able to unload since even
> the commands from the driver will not be processed due to this
> excessive back pressure.
> 
> As you indicated - once you remove the server that halts all other 
> traffic, everything else resumes - that indicates that this server
> is sending constant pause that ultimately halts the entire switch.

Thank you very much for your input Elion, you've definetively helped me
look in the right place.  I do see a constant stream of pause frames
being sent by the switch module to a F5 BIG-IP box that's connected to
external ports of the switch.  The stream appears instantly when the ESX
server is connected and vanishes just as fast when it's been
disconnected.  I haven't been able to verify what the ESX server is
doing to the switch yet, but your assumption that it too is spewing out
pause frames sounds very likely to me.

However I'm still a bit confused on why this is triggering the "NIG
timer max" message on the Linux blade.  It would have made perfect sense
to me for the bnx2x driver/NIC to stop transmitting outbound frames if
it was the recipient of an inbound pause frame flood, but tcpdump does
not show any such frames being received.  Yet it stalls all outbound
traffic.  Any idea why?

Best regards,
-- 
Tore Anderson
Redpill Linpro AS - http://www.redpill-linpro.com/
Tel: +47 21 54 41 27
