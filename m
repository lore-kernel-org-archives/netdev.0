From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH v2 3/3] pppoatm: protect against freeing of vcc
Date: Fri, 30 Nov 2012 12:12:56 -0500
Message-ID: <20121130121256.77685fef@thirdoffive.cmf.nrl.navy.mil>
References: <201211300138.qAU1c8sE003388@thirdoffive.cmf.nrl.navy.mil>
	<1354240620.21562.256.camel@shinybook.infradead.org>
	<1354263922.21562.270.camel@shinybook.infradead.org>
	<20121130095354.GA15126@shrek.podlesie.net>
	<1354277415.21562.284.camel@shinybook.infradead.org>
	<1354292626.21562.298.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Mazur <krzysiek@podlesie.net>,
	David Laight <David.Laight@ACULAB.COM>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nathan@traverse.com.au
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354292626.21562.298.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 30 Nov 2012 16:23:46 +0000
David Woodhouse <dwmw2@infradead.org> wrote:

> On Fri, 2012-11-30 at 12:10 +0000, David Woodhouse wrote:
> > In that case I think we're fine. I'll just do the same thing in
> > br2684_push(), fix up the comment you just corrected, and we're all
> > good.
> 
> OK, here's an update to me my patch 8/17 'br2684: don't send frames on
> not-ready vcc'. It takes the socket lock and does fairly much the same
> thing as your pppoatm version. It returns NETDEV_TX_BUSY and stops the
> queue if the socket is locked, and it gets woken from the ->release_cb
> callback.
> 
> I've dropped your Acked-By: since it's mostly new, but feel free to give
> me a fresh one. With this I think we're done.
> 
> Unless Chas has any objections, I'll ask Dave to pull it...

no objections.  i think this deals with my concerns.  as for splitting
the close functions, from one of your previous messages:


>Really, what we're saying is that *one* of the driver or protocol close
>functions needs to be split, and we need to do DPD or PDP. Since the
>device driver *can* abort/flush the TX queue and also any pending RX
>being handled by a tasklet, I think it makes most sense to keep it in
>the middle, with the protocol being handled first and last... which is
>the current order, as long as we consider setting ATM_VF_CLOSE to be the
>first part.

i believe this is essentially already done with the release_cb()
implementation right?  that is splitting the protocol detach/shutdown
into two parts.
