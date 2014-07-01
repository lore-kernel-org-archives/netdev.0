From: Edward Allcutt <edward.allcutt@openmarket.com>
Subject: Re: [PATCH] ipv4: icmp: Fix pMTU handling for rare case
Date: Tue, 1 Jul 2014 19:50:15 +0100 (BST)
Message-ID: <alpine.DEB.2.10.1407011912440.5997@tabini.allcutt.me.uk>
References: <1404141362-21015-1-git-send-email-edward.allcutt@openmarket.com> <20140630.234843.985671994258957329.davem@davemloft.net> <alpine.DEB.2.10.1407010937120.5997@tabini.allcutt.me.uk> <20140701.110510.2218293817137911715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140701.110510.2218293817137911715.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Jul 2014, David Miller wrote:
>> If it helps any, I've been running several production machines with
>> this patch for just about a year now (mostly running 3.10 stable
>> series).
>
> I guess if OpenBSD can wait more than 2 decades to implement proper
> path mtu handling, you can wait a year to post this bug fix :-)

Sorry about that. :-/ Some of the systems on the other end of tunnels are 
now starting to run distro kernels with this bug. I can't always convince 
them to rebuild with a patch.. I should have gotten around to this sooner.

> I still think the OpenBSD thing can't be intentional, and it's some
> bug they probably want to fix and it should therefore be investigated.
> It means performance of connections going through such machines is
> going to be crap even if I install your patch.

Making newer versions behave better won't help all the existing 
deployments. Linux should be able to cope even if it's not optimal.

The performance impact of using minimum packet size vs. optimal sizing is 
that you end up sending a bit under three times the number of packets. At 
worst. It's not ideal but it's far less bad than stalling indefinitely.

The patch won't affect performance of the normal case where more useful 
ICMP errors are received.

I did look at trying to reintroduce the original function which guessed 
the next smallest value. However since the routing cache has gone away I 
don't think there's anywhere to find out the size of previously sent 
packets without interrogating the upper protocol.. so handing the upper 
protocol the 0 value and letting it handle it seems the best approach.

Now perhaps the plateau-finding function should be reintroduced for tcp 
and other stream-oriented protocols. Is "it could be done better" enough 
reason to reject a patch that mitigates a real regression?

Is there another reason you dislike this approach?

-- 
Edward Allcutt
Senior Systems Engineer
OpenMarket | http://www.openmarket.com/
