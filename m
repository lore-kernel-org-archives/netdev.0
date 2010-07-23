From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH iptables] extension: add xt_cpu match
Date: Fri, 23 Jul 2010 16:13:08 +0200
Message-ID: <4C49A374.10700@trash.net>
References: <1279807385.2467.67.camel@edumazet-laptop>	 <alpine.LSU.2.01.1007221611510.1619@obet.zrqbmnf.qr>	 <1279811939.2467.79.camel@edumazet-laptop>  <4C497644.7050201@trash.net> <1279892621.2481.53.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1279892621.2481.53.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23.07.2010 15:43, Eric Dumazet wrote:
> extension: add xt_cpu match
> 
> Kernel 2.6.36 supports xt_cpu match
> 
> In some situations a CPU match permits a better spreading of
> connections, or select targets only for a given cpu.
> 
> With Remote Packet Steering or multiqueue NIC and appropriate IRQ
> affinities, we can distribute trafic on available cpus, per session.
> (all RX packets for a given flow are handled by a given cpu)
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

Applied to the iptables-next branch, thanks Eric.
