From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/7] CAN: Add raw protocol
Date: Sat, 22 Sep 2007 13:02:45 +0200
Message-ID: <46F4F655.5000009@trash.net>
References: <20070920184323.3795.0@janus.isnogud.escape.de>	<20070920184533.3795.3@janus.isnogud.escape.de>	<46F3BDC1.2020200@trash.net> <ygfvea3u3u2.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53406 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300AbXIVLK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2007 07:10:56 -0400
In-Reply-To: <ygfvea3u3u2.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> Patrick McHardy <kaber@trash.net> writes:
>>
>>>+config CAN_RAW_USER
>>>+	bool "Allow non-root users to access Raw CAN Protocol sockets"
>>
>>
>>If you plan to remove this option, it should happen before merging
>>since it affects userspace visible behaviour.
> 
> 
> We have discussed this and have come to the conclusion that we should
> remove permission checks completely, i.e. any user can open any CAN
> socket (raw, bcm, or whatever will be implemented in the future).
> This is because CAN is a pure broadcast network with no addresses.
> CAN frames can't be directed to only one machine or a group or to only
> one process (say one port).  There is no communication between only
> two (or some number) of stations which must be protected from other
> stations.
> 
> On the other hand, requiring a process to have CAP_NET_RAW to open a
> CAN socket would mean that such process would also be able to sniff on
> your ethernet or WLAN interfaces, which one probably wouldn't want.
> 
> We have added that check when we still allowed the CAN raw socket to
> bind to any interface and we didn't want an unprivileged process to be
> able to read all e.g. TCP/IP traffic.  Now binding is restricted to
> ARPHRD_CAN interfaces.  But even without this restriction the check is
> not necessary, since all CAN sockets can only receive and send
> ETH_P_CAN packets.  So even if there would be an encapsulation of CAN
> frames over ethernet or some other type of network, a normal user
> process opening a CAN socket would only be able to read/write CAN
> traffic, which should be OK without any special capability.
> 
> So what do you think about this?


I believe that should be fine.
