From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance
Date: Thu, 25 Aug 2005 14:22:11 -0700
Message-ID: <20050825212211.GA23384@netnation.com>
References: <20050815213855.GA17832@netnation.com> <43014E27.1070104@cosmosbay.com> <20050823190852.GA20794@netnation.com> <17163.32645.202453.145416@robur.slu.se> <20050824000158.GA8137@netnation.com> <20050825181111.GB14336@netnation.com> <20050825200543.GA6612@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20050825200543.GA6612@yakov.inr.ac.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Aug 26, 2005 at 12:05:43AM +0400, Alexey Kuznetsov wrote:

> Hello!
> 
> > something is holding the refcnt > 0 for almost all of the entries that
> > rt_garbage_collect() walks.
> 
> Did you try to look at output of "ip -s -s ro ls ca" ?
> If it is just a refcnt leakage, leaked routes should appear there
> and it is possible to guess, where they leaked.

Hi Alexey,

It appears to be just the DoS traffic I am routing through the box, as
expected, but showing a refcnt for each entry:

    cache  users 1 age 0sec mtu 1500 advmss 1460 hoplimit 64 iif eth3

I can't find in route.c what would ever decrement refcnt, and it seems to
start being set to 1.  It obviously does at some point or else the table
would stay full forever, but when I stop the DoS it falls back down. 
What part of the code will decrement the count?  I can't see it.

The DoS in this case is set up to be from a spoofed source per packet and
to the address of a remote box behind the box in question.  Forwarding is
enabled.

BTW, I hacked a busy loop into juno-z.101f.c to fine rate control and
found that with 2.6.13-rc6, it is unable to keep up with the traffic
starting at about 112 kpps (each packet being a new random source).

Simon-
