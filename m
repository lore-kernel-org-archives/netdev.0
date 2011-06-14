From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 2/2] drivers/net: Remove casts of void *
Date: Tue, 14 Jun 2011 07:00:28 -0700
Message-ID: <1308060028.18987.6.camel@Joe-Laptop>
References: <cover.1308024069.git.joe@perches.com>
	 <486a21b708a9dce0c1c0059a21a2f9b66dac9e3c.1308024069.git.joe@perches.com>
	 <BANLkTim-yLJqfxrCprwiTgdRJNy+OGDUuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	Divy Le Ray <divy@chelsio.com>,
	Breno Leitao <leitao@linux.vnet.ibm.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	Jon Mason <jdmason@kudzu.us>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Steve Hodgson <shodgson@solarflare.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Daniele Venzano <venza@brownhat
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTim-yLJqfxrCprwiTgdRJNy+OGDUuw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-06-14 at 11:21 +0200, Geert Uytterhoeven wrote:
> On Tue, Jun 14, 2011 at 06:02, Joe Perches <joe@perches.com> wrote:
> > Unnecessary casts of void * clutter the code.
> > --- a/drivers/net/a2065.c
> > +++ b/drivers/net/a2065.c
> > @@ -426,7 +426,7 @@ static irqreturn_t lance_interrupt (int irq, void *dev_id)
> >        volatile struct lance_regs *ll;
> >        int csr0;
> >
> > -       dev = (struct net_device *) dev_id;
> > +       dev = dev_id;
> 
> I think it would look better if you merge this line with the line that
> defines "dev".

I think so too, but I also think it should look like below
and that's something better done in a separate pass, don't
you think?

diff --git a/drivers/net/a2065.c b/drivers/net/a2065.c
index deaa8bc..25ea98a 100644
--- a/drivers/net/a2065.c
+++ b/drivers/net/a2065.c
@@ -421,16 +421,11 @@ static int lance_tx (struct net_device *dev)
 
 static irqreturn_t lance_interrupt (int irq, void *dev_id)
 {
-	struct net_device *dev;
-	struct lance_private *lp;
-	volatile struct lance_regs *ll;
+	struct net_device *dev = dev_id;
+	struct lance_private *lp = netdev_priv(dev);
+	volatile struct lance_regs *ll = lp->ll;
 	int csr0;
 
-	dev = (struct net_device *) dev_id;
-
-	lp = netdev_priv(dev);
-	ll = lp->ll;
-
 	ll->rap = LE_CSR0;		/* LANCE Controller Status */
 	csr0 = ll->rdp;
 
