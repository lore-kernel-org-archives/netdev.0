From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH v2 1/1] atm: remove deprecated use of pci api
Date: Wed, 14 Jan 2015 08:58:51 -0500
Message-ID: <20150114085851.234db50d@thirdoffive.cmf.nrl.navy.mil>
References: <20150112161042.GA11374@sloth>
	<20150113.215944.1703977685948196746.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lambert.quentin@gmail.com, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150113.215944.1703977685948196746.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Jan 2015 21:59:44 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

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
> 
> Thanks.

I think I would like to go through and just fix all the usages of the
older pci interface.  This patch isn't very complete due to its
automated nature.

I will make some time this weekend.
