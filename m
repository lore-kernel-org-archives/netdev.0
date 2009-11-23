From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [net-next-2.6 PATCH] net/ipv4: Move && and || to end of previous
 line
Date: Tue, 24 Nov 2009 00:32:54 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911240027280.19211@melkinpaasi.cs.helsinki.fi>
References: <4B06AC2C.3070102@gmail.com>  <20091120.092651.254794724.davem@davemloft.net> <4B08D967.80003@gmail.com>  <20091122.163112.80105623.davem@davemloft.net>  <1259000895.16503.77.camel@Joe-Laptop.home>  <alpine.DEB.2.00.0911240004530.19211@melkinpaasi.cs.helsinki.fi>
 <1259014446.16503.116.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696230645-1557981511-1259015450=:19211"
Cc: David Miller <davem@davemloft.net>,
	william.allen.simpson@gmail.com, Netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35023 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752349AbZKWWcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 17:32:53 -0500
In-Reply-To: <1259014446.16503.116.camel@Joe-Laptop.home>
Content-ID: <alpine.DEB.2.00.0911240031240.19211@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-1557981511-1259015450=:19211
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0911240031241.19211@melkinpaasi.cs.helsinki.fi>

On Mon, 23 Nov 2009, Joe Perches wrote:

> On Tue, 2009-11-24 at 00:08 +0200, Ilpo Järvinen wrote:
> > Certainly better in general already but there is still some work to be 
> > done here as now you have an && only line. I guess it mostly has to do 
> > with comments but #if... blahblahs could be another type of failure (in 
> > automation like this).
> 
> The current form is
> 
> 	if (foo 
> #ifdef BAR
> 	    && bar
> #endif
> 	   )
> 
> Another option could be:
> 
> #ifdef BAR
> 	if (foo && bar)
> #else
> 	if (foo)
> #endif
> 
> In any case, it won't be pretty.

But wouldn't your automation produce:

#ifdef BAR
	if (foo
#endif
	    &&
	    bar

? Like it did for the case where there was a comment between.

As I didn't go through the whole patch I don't know if there were in fact 
any #if things that got made into that kind of construct or not (just 
mentioned it that such places might also be affected incorrectly by your 
automation). I only noticed one of such after comment (ie., && on 
otherwise empty line) and hit reply.

-- 
 i.
---696230645-1557981511-1259015450=:19211--
