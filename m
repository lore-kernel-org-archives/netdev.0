From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH] merge sctp_opt with sctp_sock
Date: Mon, 17 Jan 2005 17:40:01 -0800 (PST)
Message-ID: <Pine.LNX.4.58.0501171718380.15927@w-sridhar.beaverton.ibm.com>
References: <41E8A17D.9040307@conectiva.com.br> <20050117133327.0386763f.davem@davemloft.net>
 <41EC626D.1010804@conectiva.com.br>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <41EC626D.1010804@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 17 Jan 2005, Arnaldo Carvalho de Melo wrote:

> David S. Miller escreveu:
> > On Sat, 15 Jan 2005 02:52:13 -0200
> > Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:
> >
> >
> >>	Please take a look and if its acceptable pull from:
> >>
> >>bk://kernel.bkbits.net/acme/connection_sock-2.6
> >>
> >>	The tricky bit here is that SCTP, to keep the existing logic,
> >>needs a way to copy only its private area from one sock to another, so
> >>I introduced a generic inet_sk_copy_descendant, that knows about the
> >>inet (v4/v6) layout (wrt inet_sock and inet6_pinfo), using this and
> >>sk->sk_prot->slab_obj_size we can copy the inet_sock descendant
> >>private area generically.
> >
> >
> > This looks fine, although I wish the descendant copying thing
> > could be done more cleanly somehow.
>
> /me too, but this is the best scheme I've found for now, perhaps in
> the future, after some more refactoring work is done/merged we can
> find some better way of doing this (tcp_create_openreq_child also
> does something like this, but does it in all the sock, perhaps
> SCTP can do something similar).

I thought you introduced this generic function so that other protocols also
may use it. If you & Dave feel that this is not clean and is going to be
needed only by SCTP, SCTP also could do a memcpy of the entire sock instead
of only sctp private area before calling sctp_sock_migrate although it is not
very straightforward. Let me know if i should work on a patch to do that.

Thanks
Sridhar
