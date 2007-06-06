From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Wed, 06 Jun 2007 13:39:16 +0200
Message-ID: <46669CE4.7060403@trash.net>
References: <20070530131123.10843.0@janus.isnogud.escape.de>	<20070530131204.10843.5@janus.isnogud.escape.de>	<465DB0B6.109@trash.net> <465F2F20.6090700@hartkopp.net>	<46603340.2050309@trash.net> <46613DBE.3010602@hartkopp.net>	<4661CBE7.7040901@hartkopp.net> <46631396.8030004@hartkopp.net>	<4663FD57.3020601@trash.net> <ygfabvfrirr.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51340 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762396AbXFFLjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 07:39:41 -0400
In-Reply-To: <ygfabvfrirr.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
>>I don't get why you can't directly check the socket option on the
>>TX path.
> 
> 
> We have several types of sockets in the PF_CAN family, two of which
> are GPL'ed and which are in the patch series.  These are CAN_RAW and
> CAN_BCM.  The protocol implementations use can_send() in af_can.c to
> send a CAN frame and indicate to can_send() in an int argument,
> whether this frame should be looped back.  Only the raw protocol has a
> socket option (setsockopt(2)) in struct raw_sock for this, bcm always
> sets this to 1 to have the frame looped back.  There is no option in
> struct bcm_sock for this.  In can_send() and in the driver we don't
> know what type of socket skb->sk points to and can't check that
> option.  Changing this would mean we have to add such an option in the
> same position in all CAN socket types and set it to fixed values in
> some of them (e.g. to 1 for bcm).  While it's doable, I wouldn't like
> that very much.
> 
> Is there anything that prevents can_send() from using skb->pkt_type to
> pass the loopback flag down to the driver?


No, that should be fine, in fact it should set it anyway even if you
can't use it for this purpose.

