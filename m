From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: net/netfilter: KASAN: stack-out-of-bounds in tcp_packet
Date: Mon, 28 Mar 2016 13:07:34 -0700
Message-ID: <1459195654.6473.122.camel@edumazet-glaptop3.roam.corp.google.com>
References: <56F8987B.5030501@gmail.com> <56F92E21.30509@gmail.com>
	 <alpine.DEB.2.10.1603281844200.23985@blackhole.kfki.hu>
	 <20160328.152959.1109841569654352040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kadlec@blackhole.kfki.hu, sploving1@gmail.com, pablo@netfilter.org,
	kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160328.152959.1109841569654352040.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-03-28 at 15:29 -0400, David Miller wrote:
> From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
> Date: Mon, 28 Mar 2016 18:48:51 +0200 (CEST)
> 
> >> > > @@ -3716,6 +3716,8 @@ void tcp_parse_options(const struct sk_buff *skb,
> >> > >               length--;
> >> > >               continue;
> >> > >           default:
> >> > > +            if (length < 2)
> >> > > +                return;
> >> > >               opsize = *ptr++;
> >> > >               if (opsize < 2) /* "silly options" */
> >> > >                   return;
> 
> I'm trying to figure out how this can even matter.
> 
> If we are in the loop, length is at least one.
> 
> That means it is legal to read the opsize byte.
> 
> By the next check, opsize is at least 2.
> 
> And then the very next line in this code makes sure length >= opsize:
> 
> 			if (opsize > length)
> 				return;	/* don't parse partial options */
> 
> Therefore no out-of-range access is possible as far as I can see.

Maybe use kasan_disable_current() and kasan_enable_current() to silence
kasan ?

Oh wait, these are not BH safe.




