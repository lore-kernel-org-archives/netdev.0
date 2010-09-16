From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2] drivers/net/usb/hso.c: prevent reading
 uninitialized memory
Date: Thu, 16 Sep 2010 12:52:40 -0400
Message-ID: <1284655960.23787.34.camel@gandalf.stny.rr.com>
References: <1284587008.6275.95.camel@dan>
	 <20100916155745.GB14318@home.goodmis.org>
	 <20100916180710.07821bdd@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Dan Rosenberg <drosenberg@vsecurity.com>, j.dumon@option.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org, davem@davemloft.net, stable@kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100916180710.07821bdd@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-09-16 at 18:07 +0100, Alan Cox wrote:
> ->tiocmget;
> > >  
> > > +	memset(&icount, 0, sizeof(struct serial_icounter_struct));
> > > +
> > 
> > Move the above to after the spinlocks.
> 
> Why - its a local variable ?
> 
> Easier to write
> 
> 	struct serial_icounter_struct icount = { 0 };
> 
> though

True, but if we want to micro-optimize, moving it after the spinlocks
means we do no zero initialization in the tiocmget == 0. Although gcc
may be smart enough to realize that too.

-- Steve
