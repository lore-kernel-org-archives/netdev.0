From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 6530] New: MAINLINE
Date: Wed, 10 May 2006 22:56:33 -0700
Message-ID: <20060510225633.1b53d4f8.akpm@osdl.org>
References: <200605100920.k4A9KC91018259@fire-2.osdl.org>
	<20060510023357.0d1260ee.akpm@osdl.org>
	<17505.49174.848331.686297@cargo.ozlabs.ibm.com>
	<1147326683.29448.80.camel@tahini.andynet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org, xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:28307 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965127AbWEKF7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 May 2006 01:59:35 -0400
To: Andy Gay <andy@andynet.net>
In-Reply-To: <1147326683.29448.80.camel@tahini.andynet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gay <andy@andynet.net> wrote:
>
> On Wed, 2006-05-10 at 20:27 +1000, Paul Mackerras wrote:
> > Andrew Morton writes:
> > 
> > > hm, a PPP fix.  We seem to need some of those lately.
> > > 
> > > Paul, does this look sane?
> > 
> > /me pages in 7 year old code...
> > 
> > > @@ -516,6 +516,8 @@ static void ppp_async_process(unsigned l
> > >  	/* try to push more stuff out */
> > >  	if (test_bit(XMIT_WAKEUP, &ap->xmit_flags) && ppp_async_push(ap))
> > >  		ppp_output_wakeup(&ap->chan);
> > > +	else if (test_bit(XMIT_FULL, &ap->xmit_flags))
> > > +		ppp_asynctty_wakeup(ap->tty);
> > 
> > ppp_asynctty_wakeup is supposed to be called by the serial driver when
> > it can take more output.
> 
> How does the serial driver know it has to call ppp_asynctty_wakeup()?
> I'd have thought it wouldn't know or care if it's being used for ppp or
> any other async traffic.

xeb (who forgot to do reply-to-all) tells me that pptpd uses ptys.

