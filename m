From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] sky2: Fix WARNING: at lib/dma-debug.c:902 check_sync
Date: Wed, 20 Jan 2010 22:24:14 +0000
Message-ID: <20100120222414.57909d14@lxorguk.ukuu.org.uk>
References: <20100120094103.GA6225@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Michael Breuer <mbreuer@majjas.com>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754623Ab0ATWXX@vger.kernel.org>
In-Reply-To: <20100120094103.GA6225@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Seems like an underlying bug in the DMA api. Maybe it just can't
> > handle operations on partial mapping.
> > 
> > Other drivers with same problem:
> >   bnx2, cassini, pcnet32, r8169, rrunner, skge, sungem, tg3, 
> 
> It seems using the same length (even without pci_unmap_len()) is
> crucial here, but I hope maintainers (added to CC) will take care.

The API needs fixing - if you've got a large mapping and you want to sync
part of it then we need to support that. Now it might well be that the
implementation on some braindead platform has to sync the entire thing,
and some implementations entire pages or cache lines.

You can't fix this in the drivers, they requested a service and they
don't have enough information nor is it their job to know about all the
platform specific rules.

Alan
