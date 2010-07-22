From: Franchoze Eric <franchoze@yandex.ru>
Subject: Re: Re: Fwd: LVS on local node
Date: Thu, 22 Jul 2010 22:45:33 +0400
Message-ID: <125461279824333@web13.yandex.ru>
References: <27901279770680@web67.yandex.ru> <1279781811.2405.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: wensong@linux-vs.org, lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1279781811.2405.15.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>  > I will be happy to hear any idea how to do connection in this environment.
>  > 
>  
>  lvs seems not very SMP friendly and a bit complex.
>  
>  I would use an iptables setup and a slighly modified REDIRECT target
>  (and/or a nf_nat_setup_info() change)
>  
>  Say you have 8 daemons listening on different ports (1000 to 1007)
>  
>  iptables -t nat -A PREROUTING -p tcp --dport 1234 -j REDIRECT --rxhash-dist --to-port 1000-1007
>  
>  rxhash would be provided by RPS on recent kernels or locally computed if
>  not already provided by core network (or old kernel)
>  
>  This rule would be triggered only at connection establishment.
>  conntracking take care of following packets and is SMP friendly.
>  

Thanks Eric,  your solution woks (I checked  with  -A PREROUTING  -j DNAT).  But there were 3 reasons why I wanted to do it with LVS:
1. use more smart schedules than simple random (schedule according to number connections or try make equal network load to all ports).
2. keepalive. LVS knows if service is dead or does not respond and skips route connections to it.
3. connection tracking - statistic how many clients on each port and were they were switched.
