From: Adrian Bunk <bunk@kernel.org>
Subject: Re: ath9k build failure
Date: Mon, 11 Aug 2008 21:52:49 +0300
Message-ID: <20080811185249.GB1880@cs181140183.pp.htv.fi>
References: <20080811162040.ed7b8ab7.sfr@canb.auug.org.au> <20080811164657.GE6128@tesla>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Luis Rodriguez <Luis.Rodriguez@atheros.com>,
	Sujith Manoharan <Sujith.Manoharan@atheros.com>
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080811164657.GE6128@tesla>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 11, 2008 at 09:46:57AM -0700, Luis R. Rodriguez wrote:
> On Sun, Aug 10, 2008 at 11:20:40PM -0700, Stephen Rothwell wrote:
> > Hi all,
> > 
> > Today's linux-next build (powerpc allyesconfig) failed like this:
> > 
> > drivers/net/wireless/ath9k/hw.c: In function 'ath9k_hw_spur_mitigate':
> > drivers/net/wireless/ath9k/hw.c:4925: internal compiler error: in expand_expr_real_1, at expr.c:9199
> > 
> > This is a driver that is in Linus' tree and has no patches in the
> > linux-next tree.
> > 
> > The original work around talked about applying the patch twice, so I
> > applied the below patch.
> 
> Stephen,
> 
> this is also in wireless-testing. I also see this in linux-2.6
> under b08cbcd4546445740c2a04291204b56f8baf7be2. Not sure how this didn't
> get through linux-next.

It seems the following I said (for pointing out that having twice the 
same code is a good indication that common code should be factored out)
was too subtle a joke:

  The patch has to be applied twice for fixing both copies of the
  same code.  :-)

When I said it has to be applied twice I really meant what I said:

$ git-show b08cbcd4 | patch -p1
patching file drivers/net/wireless/ath9k/hw.c
Hunk #1 succeeded at 5017 (offset 216 lines).
$ grep 37014 drivers/net/wireless/ath9k/hw.c
                        /* workaround for gcc bug #37014 */
                        /* workaround for gcc bug #37014 */
$ 

>   Luis

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
