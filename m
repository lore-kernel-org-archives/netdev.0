From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sat, 05 Aug 2006 19:21:13 -0400
Message-ID: <1154820073.5517.38.camel@jzny2>
References: <Pine.WNT.4.63.0608030925100.3396@jbrandeb-desk.amr.corp.intel.com>
	 <1154628302.3117.15.camel@rh4> <1154642918.5187.13.camel@jzny2>
	 <1154650197.3117.32.camel@rh4> <20060804011027.GC12085@gondor.apana.org.au>
	 <20060804083734.GA16082@gondor.apana.org.au>
	 <20060804101017.GA17393@gondor.apana.org.au>
	 <1154686563.5187.43.camel@jzny2>
	 <20060804102557.GA17723@gondor.apana.org.au>
	 <1154819086.5517.25.camel@jzny2>
	 <20060805230655.GB25468@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:204 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1751447AbWHEXV3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 19:21:29 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1G9VSM-0005Tz-2i
	for netdev@vger.kernel.org; Sat, 05 Aug 2006 19:21:22 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060805230655.GB25468@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-06-08 at 09:06 +1000, Herbert Xu wrote:
> On Sat, Aug 05, 2006 at 07:04:46PM -0400, jamal wrote:
> > 
> > whenever __e1000_maybe_stop_tx() --> __netif_test_and_stop_queue() was 
> > called it was _guaranteed to find XOFF not set_. i.e 100% of the time. 
> 
> Hardly surprising since you only have one CPU doing the actual sending.

Would it make a difference if we had more than one? qdisc_is_running
ensures only one entering that region.

> The only time when this can happen is if we more than one CPU transmitted
> at the exatly same time.
> 

Did you mean to the same eth device? 
Note: It is very highly likely - given the way i generate traffic - that
two packets hit two different CPUs at the same time. But they will be to
different ethernet devices.

cheers,
jamal

