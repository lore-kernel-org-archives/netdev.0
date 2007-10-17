From: Patrick McHardy <kaber@trash.net>
Subject: Re: stateless 1:1 NAT
Date: Wed, 17 Oct 2007 21:44:27 +0200
Message-ID: <4716661B.3020301@trash.net>
References: <E1IhxQo-0004hF-00@gondolin.me.apana.org.au> <4716510E.3090300@andrei.myip.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48815 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754346AbXJQTog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 15:44:36 -0400
Received: from [192.168.0.100] (unknown [195.158.167.14])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by stinky.trash.net (Postfix) with ESMTP id A3127948FA
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 21:44:34 +0200 (MEST)
In-Reply-To: <4716510E.3090300@andrei.myip.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florin Andrei wrote:
> So here's the thing I'm trying to solve.
> 
> Gigabit network.
> Dual homed firewall, doing 1:1 NAT for a bunch of web servers. Some 
> protocols are allowed inbound to the servers (the external, NATed 
> addresses).
> Firewall is running CentOS 5 (kernel 2.6.18)
> 
> I run pktgen on a test machine to generate a whole lot of small UDP 
> packets with random source addresses. I send the packets to the 
> firewall, to one of the 1:1 NATed addresses, to a port that's blocked by 
> the firewall.
> Meanwhile, I'm downloading a 2GB file from a web server through the 
> firewall, in a while [ 1 ] loop, to monitor the functioning of the 
> firewall.
> 
> When I start the UDP flood, the current download is able to finish up, 
> but a new one won't start. The firewall has one of the cores pegged at 
> 100% CPU usage, with a lot of interrupts being generated all the time.
> I assume there's something related to conntrack, that's why I want to 
> test stateless rules. I assume the firewall has much less work to do if 
> it's doing everything stateless, at least at the NAT level.


Its not really related to the amount of work, conntrack has a fixed
limit of connections it will track, if you flood it with connections
it will stop accepting new ones at some point (you should see a message
about that in the ringbuffer). So as long as you have conntrack loaded
the problem will likely persist. But as I wrote, previously, 2.6.23 has
a change in the eviction algorithm that should make it behave much
better in the scenario you describe. It would be interesting if you
could test that. Alternatively you could of course just increase the
maximum number of conntracks.

> Is it going to be possible to combine stateless 1:1 NAT with stateful 
> filtering?


Yes, but that probably won't solve your problem.

> By the way:
> OpenBSD 4.1 as a firewall fails even worse in this test case (it freezes 
> instantly).
> OpenBSD 4.2 works fine under the UDP flood, as if nothing happened.


And Linux 2.6.23? :)

