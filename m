From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] af_pppox: create module infrastructure for protocol modules
Date: Tue, 29 Apr 2003 03:54:19 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429065419.GN25361@conectiva.com.br>
References: <20030429061227.GJ25361@conectiva.com.br> <20030428.222728.48508327.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mostrows@speakeasy.net, netdev@oss.sgi.com, maxk@qualcomm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030428.222728.48508327.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Mon, Apr 28, 2003 at 10:27:28PM -0700, David S. Miller escreveu:
>    From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
>    Date: Tue, 29 Apr 2003 03:12:27 -0300
> 
>    	Max, take a look and see if this same approach can be used in
>    bluetooth, I bet it can, its just a matter of not using struct
>    net_proto_family for bt_proto, just like pppox already was doing
>    before my changes :-)
> 
> Something similar can be done for ipv4/ipv6 by adding a struct module
> *owner member to struct inet_protosw etc. etc.

yes
 
> Although the idea is conceptually sound, you miss one crucial thing.
> Such struct sock's reference _TWO_ modules, the "PPPOE" module
> and the "PPPOX" module.

But what is the problem? at pppox_sk_alloc time I bump the PPPOE module refcnt,
making it safe, then it calls sk_alloc where it bumps the PPPOX module, making
it safe as well, so I'm taking care of both PPPOE and PPPOX.

> So in the TCP/UDP/SCTP example case, a struct sock references the
> TCP/UDP/SCTP module _AND_ the ipv4/ipv6 module.

ditto

> So what we'll need to do is use two owner pointers in struct sock,
> one for propagating the "struct socket" owner, and one for the
> "sub-protocol".
> 
> 	struct module	*owner;

This one is the net_families[net_family]->owner

> 	struct module	*sub_owner;

this one is the pppox_protos[protocol]->owner

I thought about it, but I don't see why the current scheme doesn't handle
it, care to elaborate a bit more? I don't doubt that I may be missing some
subtlety :-)

- Arnaldo
