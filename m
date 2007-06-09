From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Sat, 09 Jun 2007 10:36:17 -0400
Message-ID: <1181399777.4077.40.camel@localhost>
References: <1181253445.4071.4.camel@localhost>
	 <20070607.154421.109060486.davem@davemloft.net>
	 <1181256848.4071.57.camel@localhost>
	 <20070607.160035.00774597.davem@davemloft.net>
	 <1181262703.3688.10.camel@w-sridhar2.beaverton.ibm.com>
	 <1181266536.4741.27.camel@localhost>
	 <20070608103925.GA23598@gondor.apana.org.au>
	 <1181302497.4063.37.camel@localhost>
	 <20070608123735.GA24582@gondor.apana.org.au>
	 <1181308372.4063.126.camel@localhost>
	 <20070609110819.GA3092@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>, auke-jan.h.kok@intel.com,
	jeff@garzik.org, kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:31719 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052AbXFIOgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2007 10:36:22 -0400
Received: by py-out-1112.google.com with SMTP id a29so1757693pyi
        for <netdev@vger.kernel.org>; Sat, 09 Jun 2007 07:36:21 -0700 (PDT)
In-Reply-To: <20070609110819.GA3092@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-09-06 at 21:08 +1000, Herbert Xu wrote:

> It takes the tx_lock in the xmit routine as well as in the clean-up
> routine.  However, the lock is only taken when it updates the queue
> status.
> 
> Thanks to the ring buffer structure the rest of the clean-up/xmit code
> will run concurrently just fine.

I know you are a patient man Herbert - so please explain slowly (if that
doesnt make sense on email, then bear with me as usual) ;->

- it seems the cleverness is that some parts of the ring description are
written to on tx but not rx (and vice-versa), correct? example the
next_to_watch/use bits. If thats a yes - there at least should have been
a big fat comment on the code so nobody changes it;
- and even if thats the case, 
a) then the tx_lock sounds unneeded, correct? (given the RUNNING
atomicity).
b) do you even need the adapter lock? ;-> given the nature of the NAPI
poll only one CPU can prune the descriptors.

I have tested with just getting rid of tx_lock and it worked fine. I
havent tried removing the adapter lock.

cheers,
jamal



