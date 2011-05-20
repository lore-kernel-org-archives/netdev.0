From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH net-next 1/2] tg3: Fix NETIF_F_LOOPBACK error
Date: Thu, 19 May 2011 18:59:34 -0700
Message-ID: <20110520015934.GA2258@mcarlson.broadcom.com>
References: <1305853864-2135-2-git-send-email-mcarlson@broadcom.com>
 <BANLkTi==K_eTcqQ39HwcBcg9AyuMLuhz6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"David Miller" <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: "Mahesh Bandewar" <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4740 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934674Ab1ETBjx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2011 21:39:53 -0400
In-Reply-To: <BANLkTi==K_eTcqQ39HwcBcg9AyuMLuhz6w@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 19, 2011 at 06:15:18PM -0700, Mahesh Bandewar wrote:
> On Thu, May 19, 2011 at 6:11 PM, Matt Carlson <mcarlson@broadcom.com> wrote:
> > Mahesh Bandewar noticed that the features cleanup in commit
> > 0da0606f493c5cdab74bdcc96b12f4305ad94085, entitled
> > "tg3: Consolidate all netdev feature assignments", mistakenly sets
> > NETIF_F_LOOPBACK by default. ?This patch corrects the error.
> >
> > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > ---
> > ?drivers/net/tg3.c | ? ?3 ++-
> > ?1 files changed, 2 insertions(+), 1 deletions(-)
> >
> > diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> > index 012ce70..0b78c5d 100644
> > --- a/drivers/net/tg3.c
> > +++ b/drivers/net/tg3.c
> > @@ -15080,6 +15080,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
> > ? ? ? ? ? ? ? ? ? ? ? ?features |= NETIF_F_TSO_ECN;
> > ? ? ? ?}
> >
> > + ? ? ? dev->features |= features;
> > +
> > ? ? ? ?/*
> > ? ? ? ? * Add loopback capability only for a subset of devices that support
> > ? ? ? ? * MAC-LOOPBACK. Eventually this need to be enhanced to allow INT-PHY
> > @@ -15090,7 +15092,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
> > ? ? ? ? ? ? ? ?/* Add the loopback capability */
> > ? ? ? ? ? ? ? ?features |= NETIF_F_LOOPBACK;
> >
> > - ? ? ? dev->features |= features;
> > ? ? ? ?dev->hw_features |= features;
> > ? ? ? ?dev->vlan_features |= features;
> I think this line should go up too. Otherwise newly created vlan
> device(s) will have spurious loopback bit set.

Yes.  You are right.  I thought vlan_features functioned like
hw_features.

