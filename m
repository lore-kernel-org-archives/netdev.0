From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH 6/9] irda: use sock slab cache
Date: Thu, 20 Jan 2005 09:25:22 -0800
Message-ID: <20050120172522.GF6839@bougret.hpl.hp.com>
References: <41EF11AF.70203@conectiva.com.br> <20050120021607.GA11216@bougret.hpl.hp.com> <41EF29BE.2020807@conectiva.com.br> <20050120085454.GA31160@infradead.org> <41EFC671.6000706@conectiva.com.br> <41EFCC51.8030700@conectiva.com.br>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        irda-users@lists.sourceforge.net, netdev@oss.sgi.com,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Content-Disposition: inline
In-Reply-To: <41EFCC51.8030700@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 20, 2005 at 01:20:49PM -0200, Arnaldo Carvalho de Melo wrote:
> Arnaldo Carvalho de Melo escreveu:
> >Christoph Hellwig escreveu:
> >
> >>On Thu, Jan 20, 2005 at 01:47:10AM -0200, Arnaldo Carvalho de Melo wrote:
> >>
> >>>>    I'm just curious about the overhead of adding a specific slab
> >>>>for IrDA sockets. Most users never create any (using IrCOMM), or
> >>>>maximum one (using Obex), so it's not like it will get a lot of use
> >>>>(except here, of course).
> >>>
> >>>
> >>>Well, lets start with something that may sound funny: when this series
> >>>of patches is finished the overhead will _decrease_ for most people.
> >>>
> >>>Why? Today we have in most machines five slab caches of this nature:
> >>>udp_sock, raw_sock, tcp_sock, unix_sock (PF_LOCAL) and the generic,
> >>>sock, that only is used by the protocols that are using 
> >>>kmalloc(pritave_sock) +
> >>>sk_protinfo.
> >>
> >>
> >>
> >>But as Jean sais this type of socket is used very little, as are a few
> >>other probably (raw, pfkey?), so maybe those should just use kmalloc +
> >>kfree instead of their own slab?

	Just to clarify, but I think you already got this nuance. I
was not talking about the frequency of people using IrDA. I just say
that when people use IrDA, they are likely to use few sockets (as
opposed to a web browser that open zillions of TCP sockets).
	There may be other socket types that falls under this
category. One example is raw socket. It's used relatively frequently,
but usually the number of raw sockets on the system is limited (how
many instance of tcpdump or ethereal will you run in parallel ?).
	On the other hand, some sockets may be seldom used, but when
used many of them are open, and therefore would justify their own slab
(on demand). Maybe ATM sockets would be a good example.

> Take a look at this patch, it shows how I think the transitional
> stage should be, the protocols will just use (IRDA for the example):

	Can't we just transition IrDA sockets to "future", rather than
"transitional". This way we are done, and no longer need to worry
about it. I mean, you already did the patch, so what's the reason of
holding back ?

	Thanks...

	Jean
