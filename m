From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: is sk->reuse truly a boolean?
Date: Tue, 20 May 2003 13:29:07 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030520162906.GF801@conectiva.com.br>
References: <20030520155744.GE801@conectiva.com.br> <20030521.011520.49126007.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20030521.011520.49126007.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Wed, May 21, 2003 at 01:15:20AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ escreveu:
> In article <20030520155744.GE801@conectiva.com.br> (at Tue, 20 May 2003 12:57:45 -0300), Arnaldo Carvalho de Melo <acme@conectiva.com.br> says:
> 
> > From what I see in the code and from references in, for instance, Unix
> > Network Programming (W. Richard Stevens) it is, but then how can this work?
> > 
> > net/ipv4/tcp_ipv4.c, line 265
> > 
> >                 if (sk->reuse > 1)
> >                         goto success;
> > 
> > In net/core/sock.c, setsockopt it just assigns 1 or 0, i.e. if userspace
> > passes > 1 it becomes 1, is this the intended behaviour? I think we have a 
> > bug in tcp_ipv4 or in core/sock.c 8)
> 
> Good point. However, SO_REUSEADDR works because we have tcp_bind_conflict().

mmmkay, so we have to fix it by changing the test to:

		    if (sk->reuse)
			   goto success;

Isn't it?

Another one I found in this audit:

sk->no_check, as per setsockopt is a boolean, but sunrpc code wants tree
values, does that need receiving this three values from userspace? if so we
have a bug in setsockopt, but without looking at sunrpc code I guess this is
only internal...

- Arnaldo
