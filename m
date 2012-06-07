From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: tg3: transmit timed out, resetting
Date: Thu, 7 Jun 2012 15:56:54 -0700
Message-ID: <20120607225654.GA14247@mcarlson.broadcom.com>
References: <alpine.DEB.2.01.1206041546070.5568@trent.utfs.org>
 <20120606010255.GA9991@mcarlson.broadcom.com>
 <CABawtvPE_xuamH2ysL8x0WsJMXdFV5oXPrWjMT-EC-DF_kCxxw@mail.gmail.com>
 <20120606021436.GA10714@mcarlson.broadcom.com>
 <CABawtvNVKkxAgrQqJS7FJGoswQ9ZVyJcHcNwbSJQk4yscTn8gw@mail.gmail.com>
 <1338955977.2760.3603.camel@edumazet-glaptop>
 <CABawtvOBJQ-oajFQmviOdgKCub-4n06kRW+x7nE2uyiWnoky9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Matt Carlson" <mcarlson@broadcom.com>,
	"Christian Kujau" <lists@nerdbynature.de>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: "ethan zhao" <ethan.kernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CABawtvOBJQ-oajFQmviOdgKCub-4n06kRW+x7nE2uyiWnoky9Q@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 06, 2012 at 12:52:32PM +0800, ethan zhao wrote:
> Eric,
>   That is ask for confirmation from Matt Carlson of Broadcom.
> 
> Ethan
> 
> On Wed, Jun 6, 2012 at 12:12 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Wed, 2012-06-06 at 10:29 +0800, ethan zhao wrote:
> >> So no way to fix it via firmware update or Linux driver ? :<
> >
> > Yes, but you need to cooperate, or else it might take more time than
> > necessary.
> >
> > Asking questions like that on lkml is not going to help very much.
> >
> > So, once again, we kindly ask you try a recent kernel and post
> > register dump and some additional information when transmit timeouts
> > happen.
> >
> > The 'latest kernel' is either linux-3.5.rc1, or one of David Miller
> > tree :
> >
> > http://git.kernel.org/?p=linux/kernel/git/davem/net-next.git;a=summary
> >
> > or
> >
> > http://git.kernel.org/?p=linux/kernel/git/davem/net.git;a=summary
> >
> > Thanks

Does the following patch fix your problem?


[PATCH] tg3: Apply short DMA frag workaround to 5906

5906 devices also need the short DMA fragment workaround.  This patch
makes the necessary change.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index d55df32..2db4d70 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -14275,7 +14275,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		}
 	}
 
-	if (tg3_flag(tp, 5755_PLUS))
+	if (tg3_flag(tp, 5755_PLUS) ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 		tg3_flag_set(tp, SHORT_DMA_BUG);
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
-- 
1.7.3.4
