From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH nf-next-2.6] netfilter: add xt_cpu match
Date: Fri, 23 Jul 2010 13:00:20 +0200
Message-ID: <4C497644.7050201@trash.net>
References: <1279807385.2467.67.camel@edumazet-laptop>	 <alpine.LSU.2.01.1007221611510.1619@obet.zrqbmnf.qr> <1279811939.2467.79.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35419 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752378Ab0GWLAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 07:00:22 -0400
In-Reply-To: <1279811939.2467.79.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 22.07.2010 17:18, schrieb Eric Dumazet:
> [PATCH nf-next-2.6] netfilter: add xt_cpu match
> 
> In some situations a CPU match permits a better spreading of
> connections, or select targets only for a given cpu.
> 
> With Remote Packet Steering or multiqueue NIC and appropriate IRQ
> affinities, we can distribute trafic on available cpus, per session.
> (all RX packets for a given flow is handled by a given cpu)
> 
> Some legacy applications being not SMP friendly, one way to scale a
> server is to run multiple copies of them.
> 
> Instead of randomly choosing an instance, we can use the cpu number as a
> key so that softirq handler for a whole instance is running on a single
> cpu, maximizing cache effects in TCP/UDP stacks.
> 
> Using NAT for example, a four ways machine might run four copies of
> server application, using a separate listening port for each instance,
> but still presenting an unique external port :
> 
> iptables -t nat -A PREROUTING -p tcp --dport 80 -m cpu --cpu 0 \
>         -j REDIRECT --to-port 8080
> 
> iptables -t nat -A PREROUTING -p tcp --dport 80 -m cpu --cpu 1 \
>         -j REDIRECT --to-port 8081
> 
> iptables -t nat -A PREROUTING -p tcp --dport 80 -m cpu --cpu 2 \
>         -j REDIRECT --to-port 8082
> 
> iptables -t nat -A PREROUTING -p tcp --dport 80 -m cpu --cpu 3 \
>         -j REDIRECT --to-port 8083
> 

Applied, thanks Eric.
