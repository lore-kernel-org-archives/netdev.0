From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Re: Weak host model vs .interface down
Date: Fri, 11 Jun 2010 12:50:14 -0700
Message-ID: <2297DADB-883E-4156-998A-854BE6CAC079@earthlink.net>
References: <OF1D06F11A.44DE8C5A-ONC125773F.00437856-C125773F.004425B9@transmode.se> <4C126514.30905@hp.com> <OFE6F71D1A.A94BE06C-ONC125773F.005C80CF-C125773F.005DF884@transmode.se>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-galgo.atl.sa.earthlink.net ([209.86.89.61]:48365 "EHLO
	elasmtp-galgo.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759689Ab0FKTvY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jun 2010 15:51:24 -0400
In-Reply-To: <OFE6F71D1A.A94BE06C-ONC125773F.005C80CF-C125773F.005DF884@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 11, 2010, at 10:06 AM, Joakim Tjernlund wrote:

> Rick Jones <rick.jones2@hp.com> wrote on 2010/06/11 18:32:20:
>> Joakim Tjernlund wrote:
>>> Linux uses the weak host model which makes the IP addresses part of the system
>>> rather than the interface. However consider this:
>>> 
>>> System A, eth0 connected to the network
>>> # > ifconfig eth0 192.168.1.16
>>> # > ifconfig eth1 192.168.1.17 down
>>> 
>>> System B
>>> # > ping 192.168.1.17
>>> PING 192.168.1.17 (192.168.1.17) 56(84) bytes of data.
>>> 64 bytes from 192.168.1.17: icmp_seq=1 ttl=64 time=0.618 ms
>>> 
>>> Isn't it a bit much to respond on 192.168.1.17 when its interface is down?
>> 
>> As you said at the beginning, the weak end system model presumes the IP address
>> is part of the system.  Seems to me that means unless one removes the IP address
>> from the system it is reasonable for the system to continue to respond to that
>> IP address.  Regardless of what happens to any individual interface.
> 
> The weak model doesn't go into such detail, it is assumption/impl. detail
> to assume that the ip address still is part of the system even when the interface
> is down. One could just as well define interface down as temporarly removing
> the IP address from the system too. This makes make much more sense to me and
> if you always want the system to answer on a IP adress you make it an IP alias.
> 
> Since the current behaviour is a problem to me and routers in general, can
> we change this? What is the current usage model which needs it to stay as is?
> 
>> 
>> Now, I wouldn't expect it to continue to respond to 192.168.1.17 through eth1,
>> but if eth0 is indeed connected to the same broadcast domain, given the
>> following of the weak end-system model, continuing to respond seems consistent
>> with enthusiasticaly following the weak end-system model.
> 
> Dosnt matter if it is in the same broadcast domain, you can use a bridge
> interface or dummy interface too. It will still respond to 192.168.1.17
> I can't find a way disable this behaviour, can you?
> 
> --

Guys

Isn't this the diff between models of a host/end system and a 
router/intermediate system?

Can you verify that xmit capability on the intf is disabled with the 
down arg?

IMO, One possible behaviour is to allow the receipt of a magic
packet to bring up a down system for the "energy star protocol".

Mitchell Erblich



		

		
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

