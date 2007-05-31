From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [E1000-devel] REGRESSION: panic on e1000 driver
Date: Fri, 1 Jun 2007 07:48:12 +1000
Message-ID: <20070531214812.GA9309@gondor.apana.org.au>
References: <1180560150.29081.35.camel@deimos.americas.hpqcorp.net> <20070531010814.GA30709@gondor.apana.org.au> <1180624569.23536.7.camel@athlon> <465EE86C.6080301@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Chapman <doug.chapman@hp.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2007 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751537AbXEaVs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2007 17:48:56 -0400
Content-Disposition: inline
In-Reply-To: <465EE86C.6080301@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 31, 2007 at 08:23:24AM -0700, Kok, Auke wrote:
>
> >e1000: 0000:01:02.0: e1000_probe: (PCI-X:66MHz:64-bit) 00:15:60:04:d7:f8
> >e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
> >e1000: 0000:01:02.1: e1000_probe: (PCI-X:66MHz:64-bit) 00:15:60:04:d7:f9
> >e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
> >e1000: 0000:15:02.0: e1000_probe: (PCI-X:66MHz:64-bit) 00:12:79:9e:b7:c4
> >e1000: eth2: e1000_probe: Intel(R) PRO/1000 Network Connection
> >e1000: 0000:15:02.1: e1000_probe: (PCI-X:66MHz:64-bit) 00:12:79:9e:b7:c5
> >e1000: eth3: e1000_probe: Intel(R) PRO/1000 Network Connection
> >e1000: Unexpected interrupt icr=0x4
> 
> that's indeed the link status change we fire manually to trigger the 
> watchdog run:
> 
> #define E1000_ICR_LSC           0x00000004 /* Link Status Change */

This still makes no sense.  The only triggers I can find for this occur
after e1000_irq_enable.  So unless we've got a problem with memory
barriers we shouldn't get the above printk.

Is there another trigger that happens earlier?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
