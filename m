From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [BKPATCH] Re: [PATCH][2.5.22] OOPS in tcp_v6_get_port
Date: Tue, 18 Jun 2002 01:15:39 -0300
Sender: owner-netdev@oss.sgi.com
Message-ID: <aemcaa$567$2@main.gmane.org>
References: <Pine.LNX.4.44.0206171314460.2496-300000@lain.perlfu.co.uk> <20020617.143319.54623892.davem@redhat.com> <20020618005735.GB1146@conectiva.com.br> <20020617.191726.55300824.davem@redhat.com> <20020618024934.GA4274@conectiva.com.br> <20020618035804.GA18759@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, critson@perlfu.co.uk,
   torvalds@transmeta.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20020618035804.GA18759@conectiva.com.br>
List-Id: netdev.vger.kernel.org

Em Tue, Jun 18, 2002 at 12:58:04AM -0300, Arnaldo C. Melo escreveu:
> Em Mon, Jun 17, 2002 at 11:49:34PM -0300, Arnaldo C. Melo escreveu:
> > Em Mon, Jun 17, 2002 at 07:17:26PM -0700, David S. Miller escreveu:
> > >    From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
> > >    Date: Mon, 17 Jun 2002 21:57:35 -0300
> > > 
> > >    --- orig/net/ipv6/tcp_ipv6.c	Sat May 25 23:13:56 2002
> > >    +++ linux/net/ipv6/tcp_ipv6.c	Fri Jun 14 23:23:07 2002
> > > 
> > > I've installed this change into my tree in the meantime.
> > > If we find a better fix, we can just revert this.
> > 
> > OK, I found a better fix, I think, that allowed me to kill inet6_sk_generic
> > in af_inet6.c, using a constructor for the tcpv6, udpv6 and raw6 slab caches,
> > as suggested by Russel King, I'll be sending RSN.
> 
> Here it is, David, please consider pulling it from:
> 
> http://kernel-acme.bkbits.net:8080/tcpv6-pinet6
> 
> Best Regards,
> 
> - Arnaldo

Oops, brain fart, David, please don't apply, in tcp_create_openreq_child
we overwrite the ->pinet6 field after the constructor inits it to the proper
value :( Please leave the old patch in place for a while... :(

- Arnaldo
