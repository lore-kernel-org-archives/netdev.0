From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch] NET: remove support for Davicom 9102 from the Tulip driver
Date: Fri, 04 Apr 2008 17:59:56 -0400
Message-ID: <47F6A4DC.3070504@garzik.org>
References: <Pine.SOC.4.64.0804041154150.11646@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Grant Grundler <grundler@parisc-linux.org>
To: Meelis Roos <mroos@linux.ee>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49611 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751565AbYDDWAW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 18:00:22 -0400
In-Reply-To: <Pine.SOC.4.64.0804041154150.11646@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Meelis Roos wrote:
>>> -     { 0x1282, 0x9102, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DM910X },
> 
>> applied
> 
> Hmm, did you see my yesterdays answer to that patch - that dmfe should 
> first be fixed to work on all  cards with this PCI ID? Currenty dmfe 
> fails to work on at least Sun Fire V100 and Sun Netra X1 boxes, only 
> tulip works.
> 

Maybe this tulip_core.c code needs to be applied to dmfe.c?

         if (tulip_uli_dm_quirk(pdev)) {
                 csr0 &= ~0x01f100ff;
#if defined(CONFIG_SPARC)
                 csr0 = (csr0 & ~0xff00) | 0xe000;
#endif
         }

A zeroed MAC address leads me to believe that dmfe's SROM parsing isn't 
quite as capable as tulip's, though that's just a guess.

Just checked dmfe with sparse and it reports clean, though looking at 
the code it could use some cleanups.

	Jeff



