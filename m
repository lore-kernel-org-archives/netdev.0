From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 1/1] atm: remove deprecated use of pci api
Date: Wed, 14 Jan 2015 14:47:28 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAC79B3@AcuExch.aculab.com>
References: <20150112161042.GA11374@sloth>
 <20150113.215944.1703977685948196746.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "chas@cmf.nrl.navy.mil" <chas@cmf.nrl.navy.mil>,
	"linux-atm-general@lists.sourceforge.net"
	<linux-atm-general@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>,
	"lambert.quentin@gmail.com" <lambert.quentin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150113.215944.1703977685948196746.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller
> From: Quentin Lambert <lambert.quentin@gmail.com>
> Date: Mon, 12 Jan 2015 17:10:42 +0100
> 
> > @@ -2246,7 +2246,8 @@ static int eni_init_one(struct pci_dev *pci_dev,
> >  		goto err_disable;
> >
> >  	zero = &eni_dev->zero;
> > -	zero->addr = pci_alloc_consistent(pci_dev, ENI_ZEROES_SIZE, &zero->dma);
> > +	zero->addr = dma_alloc_coherent(&pci_dev->dev, ENI_ZEROES_SIZE,
> > +					&zero->dma, GFP_ATOMIC);
> >  	if (!zero->addr)
> >  		goto err_kfree;
> >
> 
> I really would like you to look at these locations and see if
> GFP_KERNEL can be used instead of GFP_ATOMIC.  I bet that nearly
> all of these can, and it is preferred.

And there isn't much point inlining the wrapper until that has been done.
Not only that, the corresponding pci_free_consistent() calls need changing
at (much) the same time.

	David
