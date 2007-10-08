From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: pktgen question
Date: Mon, 08 Oct 2007 17:46:26 -0500
Message-ID: <470AB342.1030209@opengridcomputing.com>
References: <46F8007A.6000701@candelatech.com>	<470AA48B.4050005@opengridcomputing.com>	<470AA7B9.4070703@candelatech.com> <20071008.152234.13748626.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, rick.jones2@hp.com, hadi@cyberus.ca,
	johnpol@2ka.mipt.ru, netdev@vger.kernel.org,
	Robert.Olsson@data.slu.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:40666 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750934AbXJHWq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 18:46:28 -0400
In-Reply-To: <20071008.152234.13748626.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



David Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Mon, 08 Oct 2007 14:57:13 -0700
> 
>> This skb recycling can certainly work and has been done several
>> times before.  It never gets into the kernel though.
> 
> Because it doesn't work.
> 
> A socket can hang onto a receive packet essentially forever.
> 
> You cannot therefore rely upon the network stack to give you the
> packet back in some reasonable finite amount of time.  This is simply
> the nature of the beast.
> 
> Which means that you either:
> 
> 1) Starve and stop receiving packets when the recycling ring
>    runs out because all of those packets are stuck in socket
>    buffers.  This is easily DoS'able by users on your system
> 
> 2) End up allocating new packets anyways, but then what's the
>    point of the recycling ring?  It's just a hack that works
>    when everything goes as planned, and in real life that is
>    rarely the case.
> 
> It also makes the driver locking more complicated.  Packet
> input occurs in NAPI drivers via netif_receive_skb() which
> would be capable of recycling packets back to the same
> driver in a recycling scheme.  But the recycling can occur
> from other contexts too.  The netif_receive_skb() caller
> already has atomic access to the receive queue, but those
> other callback cases do not.
> 
> That locking issue is just the tip of the iceberg.  Once you
> start discussing solutions, all sorts of new issues begin to
> pop up.
> 
> SKB recycling, just say no.
> 

We're talking about just for pktgen...eh?



