From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: [RFC PATCH] fix problems with NETIF_F_HIGHDMA in networking drivers
Date: Sat, 27 Feb 2010 12:59:31 +0100
Message-ID: <201002271259.31596.bzolnier@gmail.com>
References: <51f3faa71002260646r705891e8tdbab1f6faeeb4b81@mail.gmail.com> <51f3faa71002261908y7cfa62eeicb3e56d5c920887a@mail.gmail.com> <20100227.015350.71138134.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: hancockrwd@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f219.google.com ([209.85.220.219]:46121 "EHLO
	mail-fx0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966055Ab0B0MAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 07:00:39 -0500
In-Reply-To: <20100227.015350.71138134.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 27 February 2010 10:53:50 am David Miller wrote:
> From: Robert Hancock <hancockrwd@gmail.com>
> Date: Fri, 26 Feb 2010 21:08:04 -0600
> 
> > That seems like a reasonable approach to me. Only question is how to
> > implement the check for DMA_64BIT. Can we just check page_to_phys on
> > each of the pages in the skb to see if it's > 0xffffffff ? Are there
> > any architectures where it's more complicated than that?
> 
> On almost every platform it's "more complicated than that".

Mildly speaking, I see the real problem now and it is much higher in
the software stack than networking..

> This is the whole issue.  What matters is the final DMA address and
> since we have IOMMUs and the like, it is absolutely not tenable to
> solve this by checking physical address attributes.

What's more we may not have IOMMU in place which creates really interesting
scenarios for HIGHMEM=y and results in all kind of wonderful band-aids in
particular device drivers.

Having IOMMU (even if it is only a software one, i.e. this would mean
swiotlb for x86-32/highmem) always in place would simplify things greatly..

--
Bartlomiej Zolnierkiewicz
