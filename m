From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [patch RFC 3/3] b44: convert to ssb module
Date: Tue, 15 Aug 2006 16:14:16 +0200
Message-ID: <200608151614.16640.mb@bu3sch.de>
References: <200608150014.19661.mb@bu3sch.de> <200608150018.39548.mb@bu3sch.de> <20060815121248.GA28544@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de,
	zambrano@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:53688
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S965374AbWHOOPw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 10:15:52 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060815121248.GA28544@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 15 August 2006 14:12, John W. Linville wrote:
> On Tue, Aug 15, 2006 at 12:18:39AM +0200, Michael Buesch wrote:
> 
> > @@ -2093,13 +2015,13 @@
> >  	bp->imask = IMASK_DEF;
> >  
> >  	bp->core_unit = ssb_core_unit(bp);
> > -	bp->dma_offset = SB_PCI_DMA;
> > +	bp->dma_offset = 0x40000000; /* Client Mode PCI memory access space (1GB) */
> 
> Probably shouldn't change anything to a magic number...

Well, SB_PCI_DMA wasn't really a useful name, too IMHO :)
But you're right. We should use a define. And I know that.
This is only a patch for testing if it actually works with the
ssb module (I can not test this).

Besides that, we should probably get rid of dma_offset completely,
as it is not really an offset, but a routing bit.

You can take a look at the new DMA engine code of bcm43xx.
It's the same engine.

BTW: John, I see that the new DMA engine code is not applied
to wireless-dev (64-bit DMA and >1G support). But I think I
already sent the patch. Where did it get lost? Was it my fault?

-- 
Greetings Michael.
