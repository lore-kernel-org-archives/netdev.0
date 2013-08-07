From: Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Patch net-next v2 5/8] sunrpc: use generic union inet_addr
Date: Wed, 07 Aug 2013 20:27:26 +0800
Message-ID: <1375878446.11370.36.camel@cr0>
References: <1375427674-21735-1-git-send-email-amwang@redhat.com>
	 <1375427674-21735-6-git-send-email-amwang@redhat.com>
	 <20130802093625.2c70a330@tlielax.poochiereds.net>
	 <1375672445.32485.8.camel@cr0>
	 <20130806062801.67714276@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130806062801.67714276-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-08-06 at 06:28 -0400, Jeff Layton wrote:
> 
> My question is a bit more fundamental: Why are you using this new union
> in your patches instead of simply passing around "struct sockaddr"
> pointers? If you did that, then you could simply replace all of the
> rpc_* wrappers with your generic ones, since you wouldn't need to do
> the cast to this (seemingly unnecessary) union.

Because there are some places have to interpret the structure, without
this union, they need to cast to either sockaddr_in or sockaddr_in6
first, which is not as pretty as using a union.

For example, the code in netpoll:

ipv6_addr_equal(daddr, &np->local_ip.sin6.sin6_addr)

without the union, it would be:

struct sockaddr_in6 *addr = (struct sockaddr_in6 *) &np->local_ip;
ipv6_addr_equal(daddr, addr->sin6_addr);

> 
> FWIW, I too am happy to see these routines moved to common code. I just
> wonder whether it might make more sense to use the existing convention
> instead of this new union.
> 

Thanks.

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
