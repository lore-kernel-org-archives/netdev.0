From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: '< 0' test on unsigned
Date: Sun, 01 Mar 2009 20:36:43 -0800 (PST)
Message-ID: <20090301.203643.105143832.davem@davemloft.net>
References: <49AAF989.8070000@gmail.com>
	<20090302043056.GA16090@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60934
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752127AbZCBEhC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 23:37:02 -0500
In-Reply-To: <20090302043056.GA16090@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 2 Mar 2009 12:30:56 +0800

> Roel Kluin <roel.kluin@gmail.com> wrote:
> >
> > diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
> > index 25524d4..0b9d63f 100644
> > --- a/net/ipv4/tcp_probe.c
> > +++ b/net/ipv4/tcp_probe.c
> > @@ -167,7 +167,7 @@ static ssize_t tcpprobe_read(struct file *file, char __user *buf,
> > {
> >        int error = 0, cnt = 0;
> > 
> > -       if (!buf || len < 0)
> > +       if (!buf || (ssize_t)len < 0)
> >                return -EINVAL;
> > 
> >        while (cnt < len) {
> 
> Either cnt needs to be promoted, or you need to limit len to INT_MAX.

Right, since the positive range of 'size_t' can exceed that of 'int'
