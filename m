From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH v2 3/3] pppoatm: protect against freeing of vcc
Date: Wed, 28 Nov 2012 16:20:01 -0500
Message-ID: <20121128162001.3f326720@thirdoffive.cmf.nrl.navy.mil>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
	<1350926091-12642-3-git-send-email-krzysiek@podlesie.net>
	<1354036592.2534.6.camel@shinybook.infradead.org>
	<20121127173906.GA11390@shrek.podlesie.net>
	<1354039349.2534.11.camel@shinybook.infradead.org>
	<20121127182843.GA11597@shrek.podlesie.net>
	<20121128201837.GA912@shrek.podlesie.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Woodhouse <dwmw2@infradead.org>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Krzysztof Mazur <krzysiek@podlesie.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121128201837.GA912@shrek.podlesie.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 28 Nov 2012 21:18:37 +0100
Krzysztof Mazur <krzysiek@podlesie.net> wrote:

> On Tue, Nov 27, 2012 at 07:28:43PM +0100, Krzysztof Mazur wrote:
> > I think that we should add atm_pop() function that does that and fix all
> > drivers.
> > 
> 
> I'm sending a patch that implements that idea.
> 
> Currently we need two arguments vcc and skb. However, we have reserved
> ATM_SKB(skb)->vcc in skb control block for keeping vcc
> and we can create single argument version vcc_pop(skb). In that case
> we need to move:
> 
> 	ATM_SKB(skb)->vcc = vcc;
> 
> from ATM drivers to functions that call atmdev_ops->send().

i dont like the vcc->pop() implementation and at one point i had the
crazy idea of using skb->destructors to handle it.  however, i think it
would be necessary to clone the skb's so any existing destructor is
preserved.

> +#define vcc_pop(vcc, skb) vcc_pop_any(vcc, skb)
> +#define vcc_pop_irq(vcc, skb) vcc_pop_any(vcc, skb)

don't define these if you dont plan on using them anway.
