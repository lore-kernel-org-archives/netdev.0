From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sat, 05 Aug 2006 19:04:46 -0400
Message-ID: <1154819086.5517.25.camel@jzny2>
References: <E1G8dmn-0001hH-00@gondolin.me.apana.org.au>
	 <Pine.WNT.4.63.0608030925100.3396@jbrandeb-desk.amr.corp.intel.com>
	 <1154628302.3117.15.camel@rh4> <1154642918.5187.13.camel@jzny2>
	 <1154650197.3117.32.camel@rh4> <20060804011027.GC12085@gondor.apana.org.au>
	 <20060804083734.GA16082@gondor.apana.org.au>
	 <20060804101017.GA17393@gondor.apana.org.au>
	 <1154686563.5187.43.camel@jzny2>
	 <20060804102557.GA17723@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:41145 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1751383AbWHEXEt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 19:04:49 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1G9VCR-0000bQ-3s
	for netdev@vger.kernel.org; Sat, 05 Aug 2006 19:04:55 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060804102557.GA17723@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-04-08 at 20:25 +1000, Herbert Xu wrote:
> On Fri, Aug 04, 2006 at 06:16:03AM -0400, jamal wrote:
> > 
> > I still have my setup intact, so i will give this a whirl in about 3-4
> > hours. It does look promising - an atomic should be a lot cheaper than a
> > lock. Thanks Herbert.
> 
> Well it's not that good since the current code only takes the
> lock in exceptional circumstances while my patch does the atomic
> op unconditionally.

I run a variety of tests and it looks good i.e performance wise,
although lower than what i had before, certainly is an improvement over
what was there before (by about 1kpps in forwarding). It would probably
chew more CPU than the original driver (given the atomic) but as i said
before i have no philosophical qualms with that since it performs better
under stress ;->

Hardware is:
Dual via C3 1Ghz with a dual port e1000. The bottleneck is really
the 32 bit PCI bus in most cases. I tried running single port, dual;
low traffic, high traffic etc.

Interesting thing i noticed:
Under high speed forwarding test bidirectional (eth0<--forwarding-->eth1)

whenever __e1000_maybe_stop_tx() --> __netif_test_and_stop_queue() was 
called it was _guaranteed to find XOFF not set_. i.e 100% of the time. 

This seems to actually happen on eth0 only (i think the two ports share
the same PCI bridge and probably eth0 is biased?).

If you want me to try something else, send an incremental patch and i
can do it tomorrow.

cheers,
jamal 

