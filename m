From: "Mark E Mason" <mason@broadcom.com>
Subject: RE: [PATCH] NAPI support for Sibyte MAC
Date: Mon, 26 Mar 2007 14:33:57 -0700
Message-ID: <7E000E7F06B05C49BDBB769ADAF44D070206E93D@NT-SJCA-0750.brcm.ad.broadcom.com>
References: <460580BF.4040904@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org
To: "Sergei Shtylyov" <sshtylyov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3992 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932569AbXCZVeZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2007 17:34:25 -0400
Content-class: urn:content-classes:message
In-Reply-To: <460580BF.4040904@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, 

> -----Original Message-----
> From: Sergei Shtylyov [mailto:sshtylyov@ru.mvista.com] 
> Sent: Saturday, March 24, 2007 12:49 PM
> To: Mark E Mason
> Cc: linux-mips@linux-mips.org; netdev@vger.kernel.org
> Subject: Re: [PATCH] NAPI support for Sibyte MAC

[snip]
> > @@ -2075,12 +2143,52 @@
> >  		 */
> >  
> >  		if (isr & (M_MAC_INT_CHANNEL << S_MAC_TX_CH0)) {
> > -			sbdma_tx_process(sc,&(sc->sbm_txdma));
> > +			sbdma_tx_process(sc,&(sc->sbm_txdma), 0);
> > +#ifdef CONFIG_NETPOLL_TRAP
> > +		       if (netpoll_trap()) {
> > +			       if 
> (test_and_clear_bit(__LINK_STATE_XOFF, &dev->state)) 
> > +				       __netif_schedule(dev);
> > +		       }
> > +#endif
> >  		}
> 
>     This just doesn't make sense. That option is enabled to 
> *prevent* calls to 
> __netif_schedule() -- you can't override it that way. (Well, 
> how it works 
> currently, doesn't make much sense either since it totally 
> breaks the TX queue 
> control -- I was going to post a patch).

I'll admit - this was just copied over from the non-NAPI version we
started with ;-).

Are you saying that the #ifdef test should simply be an #ifndef here?

[I'm working on a revised patch based on feedback from Ralf and others
which removes the Kconfig option for NAPI - it'll just be on, all the
time.]

Thanks,
Mark

