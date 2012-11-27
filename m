From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH v2 3/3] pppoatm: protect against freeing of vcc
Date: Tue, 27 Nov 2012 13:54:34 -0500
Message-ID: <20121127135434.0728cd4f@thirdoffive.cmf.nrl.navy.mil>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
	<1350926091-12642-3-git-send-email-krzysiek@podlesie.net>
	<1354036592.2534.6.camel@shinybook.infradead.org>
	<20121127173906.GA11390@shrek.podlesie.net>
	<1354039349.2534.11.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Mazur <krzysiek@podlesie.net>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nathan@traverse.com.au
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354039349.2534.11.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Nov 2012 18:02:29 +0000
David Woodhouse <dwmw2@infradead.org> wrote:

> In solos-pci at least, the ops->close() function doesn't flush all
> pending skbs for this vcc before returning. So can be a tasklet
> somewhere which has loaded the address of the vcc->pop function from one
> of them, and is going to call it in some unspecified amount of time.
> 
> Should we make the device's ->close function wait for all TX and RX skbs
> for this vcc to complete? 

the driver's close routine should wait for any of the pending tx and rx
to complete.  take a look at the he.c in driver/atm
