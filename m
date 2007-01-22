From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] Re: kernel BUG in eth_alloc_tx_desc_index at drivers/net/mv643xx_eth.c:1069!
Date: Mon, 22 Jan 2007 11:02:36 +0100
Message-ID: <20070122100236.GC2079@ff.dom.local>
References: <20070109092602.GC1703@ff.dom.local> <7d01f9f00701090227v60b37e5dy6afbf70ccde58bf2@mail.gmail.com> <20070109130220.GA4060@ff.dom.local> <7d01f9f00701090944o62f39fb4yfaa5449c2d2d010d@mail.gmail.com> <20070109200541.GA27089@xyzzy.farnsworth.org> <7d01f9f00701091305n3a82713fla442a70a6098dbf@mail.gmail.com> <7d01f9f00701100912kc6fb635wd863d9563b0eb328@mail.gmail.com> <20070111104220.GA3171@ff.dom.local> <7d01f9f00701210418q6f506d20tdc9ce10b501370d7@mail.gmail.com> <7d01f9f00701210502m2bb96bd8i5071a76b6a8c3ea0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>, netdev@vger.kernel.org,
	mlachwani@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:52742 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751421AbXAVKAP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jan 2007 05:00:15 -0500
To: Thibaut VARENE <T-Bone@parisc-linux.org>
Content-Disposition: inline
In-Reply-To: <7d01f9f00701210502m2bb96bd8i5071a76b6a8c3ea0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 21, 2007 at 02:02:15PM +0100, Thibaut VARENE wrote:
> On 1/21/07, Thibaut VARENE <T-Bone@parisc-linux.org> wrote:
...
> >Hmm, I think this is guaranteed not to work. In between those lines
> >the lock is released, while data in the mp structure is still being
> >accessed. It seems that this bit of code is indeed not race-safe
> >though, I'm gonna try to figure something.

I only changed the part I was quite sure is wrong. 
I didn't know the internals of this place but thought
probably somebody had some reasons to enable irqs here.

I hope the maintainers will decide the range of necessary
changes considering your testing and the patch.

> This was indeed the right spot. The attached raw hack seems to fix the
> bug (I couldn't crash the box so far).  I haven't checked that the
> same "situation" happens elsewhere in the code, I leave that as an
> exercise for the maintainers (or until I experience another kind of
> crash :)
> 
> The patch is a bit ugly (printk with irq disabled will not show, etc)
> but at least it does work. I'm sure somebody will figure something

Congratulations and regards,

Jarek P.
