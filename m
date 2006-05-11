From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 6530] New: MAINLINE
Date: Wed, 10 May 2006 21:06:25 -0700
Message-ID: <20060510210625.7fa413e6.akpm@osdl.org>
References: <200605100920.k4A9KC91018259@fire-2.osdl.org>
	<20060510023357.0d1260ee.akpm@osdl.org>
	<17505.49174.848331.686297@cargo.ozlabs.ibm.com>
	<20060510202943.35f548db.akpm@osdl.org>
	<17506.46898.503580.4994@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:47848 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965124AbWEKEJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 May 2006 00:09:21 -0400
To: Paul Mackerras <paulus@samba.org>
In-Reply-To: <17506.46898.503580.4994@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Mackerras <paulus@samba.org> wrote:
>
> Andrew Morton writes:
> 
> > xeb has said:
> > 
> > in this construction:
> > 
> >           if ((test_bit(XMIT_WAKEUP, &ap->xmit_flags) ||
> >              test_bit(XMIT_FULL, &ap->xmit_flags)) && ppp_async_push(ap))
> >                   ppp_output_wakeup(&ap->chan);
> > 
> > if ppp_async_push() doesn't send any data i.e.  XMIT_FULL is set then all
> > (transfer) hangs up while somebody push again, for instance lcp-echo.  
> 
> If XMIT_FULL and ppp_async_push doesn't send any data, that means the
> serial driver's output buffer was full.  If that's the case, *and* we
> don't see a call to ppp_output_wakeup, then the finger points squarely
> at the serial driver as the source of the bug.
> 

OK, thanks.  So the next question is: which driver is being used?
