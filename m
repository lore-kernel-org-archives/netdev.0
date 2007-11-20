From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] LRO ack aggregation
Date: Tue, 20 Nov 2007 17:37:40 +0300
Message-ID: <20071120143740.GB30073@2ka.mipt.ru>
References: <E1IuMIQ-0003gc-00@gondolin.me.apana.org.au> <20071119.222214.81458569.davem@davemloft.net> <4742C96D.3050203@myri.com> <20071120.035558.214794900.davem@davemloft.net> <4742E0A9.2070205@myri.com> <20071120133509.GA17377@2ka.mipt.ru> <20071120135056.GA18266@gondor.apana.org.au> <20071120140312.GA6695@2ka.mipt.ru> <20071120140831.GA18465@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Gallatin <gallatin@myri.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	ossthema@de.ibm.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:45933 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752587AbXKTOiC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 09:38:02 -0500
Content-Disposition: inline
In-Reply-To: <20071120140831.GA18465@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 20, 2007 at 10:08:31PM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> Of course we still have the problem with the option in general
> that Dave raised.  That is this may cause the proliferation of
> TCP receiver behaviour that may be undesirable.

Yes, it results in bursts of traffic because of delayed acks accumulated
in sender's lro engine, but from the first point, if receiver is slow,
then it will slowly send acks and they will be slowly accumulated, thus
changing not only seq/ack numbers, but also timings, which is equal to
increasing length of the pipe between users. TCP is able to balance on 
this edge. I'm sure it depends on workload, but heavy bulk transfers,
where only lro with and without ack agregation can win, are quite usual
on long pipes with high performance numbers.

Until it is tested, I doubt it is possible to say it is 100% good or
bad, so my proposal is to write the code, which is tunable from
userspace, turn it off and allow people to test the change.

-- 
	Evgeniy Polyakov
