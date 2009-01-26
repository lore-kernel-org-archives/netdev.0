From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix setsockopt() locking errors
Date: Mon, 26 Jan 2009 12:33:51 -0800 (PST)
Message-ID: <20090126.123351.201148059.davem@davemloft.net>
References: <20090124224930.GA4456@localhost.localdomain>
	<20090126115012.GA5620@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vegard.nossum@gmail.com, mmokrejs@ribosome.natur.cuni.cz,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35586
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753293AbZAZUdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 15:33:49 -0500
In-Reply-To: <20090126115012.GA5620@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 26 Jan 2009 11:50:12 +0000

> On 24-01-2009 23:49, Vegard Nossum wrote:
> > +static int sock_linger(struct sock *sk, char __user *optval, int optlen)
> ...
> > +static int sock_set_rcvtimeo(struct sock *sk, char __user *optval, int optlen)
> > +{
> > +	int ret;
> > +	long rcvtimeo;
> > +
> > +	ret = sock_set_timeout(&rcvtimeo, optval, optlen);
> 
> A check for error is needed here and below.

Right, you cannot continue and update the socket state if this
sock_set_timeout() call returns an error.
