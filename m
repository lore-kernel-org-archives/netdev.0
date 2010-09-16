From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v2] drivers/net/usb/hso.c: prevent reading uninitialized
 memory
Date: Thu, 16 Sep 2010 18:07:10 +0100
Message-ID: <20100916180710.07821bdd@lxorguk.ukuu.org.uk>
References: <1284587008.6275.95.camel@dan>
	<20100916155745.GB14318@home.goodmis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dan Rosenberg <drosenberg@vsecurity.com>, j.dumon@option.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org, davem@davemloft.net, stable@kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:38055 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753491Ab0IPQpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 12:45:46 -0400
In-Reply-To: <20100916155745.GB14318@home.goodmis.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

->tiocmget;
> >  
> > +	memset(&icount, 0, sizeof(struct serial_icounter_struct));
> > +
> 
> Move the above to after the spinlocks.

Why - its a local variable ?

Easier to write

	struct serial_icounter_struct icount = { 0 };

though
