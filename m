From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Patch for tbench regression.
Date: Mon, 29 Sep 2008 15:20:17 +0800
Message-ID: <20080929072017.GA24300@gondor.apana.org.au>
References: <20080928211530.GA9341@2ka.mipt.ru> <20080929031244.GA22619@gondor.apana.org.au> <20080929053605.GA21663@2ka.mipt.ru> <20080929054052.GA23600@gondor.apana.org.au> <20080929055203.GA3460@2ka.mipt.ru> <20080929064006.GA23967@gondor.apana.org.au> <20080929064518.GA10653@2ka.mipt.ru> <20080929070213.GA24146@gondor.apana.org.au> <20080929071119.GA29076@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	Mel Gorman <mel@csn.ul.ie>, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@marvell.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35946 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751063AbYI2HUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 03:20:25 -0400
Content-Disposition: inline
In-Reply-To: <20080929071119.GA29076@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2008 at 11:11:19AM +0400, Evgeniy Polyakov wrote:
>
> How did you find that? :)

Because your PIC looks normal.  You'll know when you're in PV
Xen because it looks like this:

           CPU0              CPU1              
  1:          2          0        Phys-irq  i8042
  7:          0          0        Phys-irq  parport0
  8:          0          0        Phys-irq  rtc
  9:          0          0        Phys-irq  acpi
 12:          4          0        Phys-irq  i8042
 14:   14710832   47935559        Phys-irq  ide0
 15:   11484815   42035535        Phys-irq  ide1
 16:          0          0        Phys-irq  uhci_hcd:usb1
 17:          0          0        Phys-irq  libata
 18:          0          0        Phys-irq  uhci_hcd:usb5, ehci_hcd:usb6
 19:        212         90        Phys-irq  uhci_hcd:usb4, libata
 20:          0          0        Phys-irq  uhci_hcd:usb2
 21:          2          0        Phys-irq  uhci_hcd:usb3, ehci_hcd:usb7
 22: 1038949859          0        Phys-irq  peth0
 23:        216          0        Phys-irq  HDA Intel
256: 1006488099          0     Dynamic-irq  timer0
257:   64033545          0     Dynamic-irq  resched0
258:         98          0     Dynamic-irq  callfunc0
259:          0   85739450     Dynamic-irq  resched1
260:          0        183     Dynamic-irq  callfunc1
261:          0  271431605     Dynamic-irq  timer1
262:       6778      16816     Dynamic-irq  xenbus
263:          0          0     Dynamic-irq  console
NMI:          0          0 
LOC:          0          0 
ERR:          0
MIS:          0

> Yes, of course, even single empty syscall may potentially force process
> the be scheduled away, bit still performance will not be with 24/190
> ratio... Weird.

I don't think PV/FV is the issue anyway since we're both on FV :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
