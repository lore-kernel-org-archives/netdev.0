From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 6/9] irda: use sock slab cache
Date: Thu, 20 Jan 2005 08:54:54 +0000
Message-ID: <20050120085454.GA31160@infradead.org>
References: <41EF11AF.70203@conectiva.com.br> <20050120021607.GA11216@bougret.hpl.hp.com> <41EF29BE.2020807@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jt@hpl.hp.com, "David S. Miller" <davem@davemloft.net>,
        irda-users@lists.sourceforge.net, netdev@oss.sgi.com,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Content-Disposition: inline
In-Reply-To: <41EF29BE.2020807@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 20, 2005 at 01:47:10AM -0200, Arnaldo Carvalho de Melo wrote:
> >	I'm just curious about the overhead of adding a specific slab
> >for IrDA sockets. Most users never create any (using IrCOMM), or
> >maximum one (using Obex), so it's not like it will get a lot of use
> >(except here, of course).
> 
> Well, lets start with something that may sound funny: when this series
> of patches is finished the overhead will _decrease_ for most people.
> 
> Why? Today we have in most machines five slab caches of this nature:
> udp_sock, raw_sock, tcp_sock, unix_sock (PF_LOCAL) and the generic,
> sock, that only is used by the protocols that are using 
> kmalloc(pritave_sock) +
> sk_protinfo.

But as Jean sais this type of socket is used very little, as are a few
other probably (raw, pfkey?), so maybe those should just use kmalloc +
kfree instead of their own slab?
