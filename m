From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC] avoid unnecessary alignement overhead in skb->data allocation.
Date: Tue, 8 Aug 2006 09:24:08 +0400
Message-ID: <20060808052408.GA7279@2ka.mipt.ru>
References: <20060806.232339.30184217.davem@davemloft.net> <E1G9zMP-0001MO-00@gondolin.me.apana.org.au> <20060807072423.GA2078@2ka.mipt.ru> <20060807072816.GA5404@gondor.apana.org.au> <20060807073103.GA11283@2ka.mipt.ru> <20060807073919.GA5582@gondor.apana.org.au> <4807377b0608071709j26da1092la20f1589c7b90df7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	chris.leech@gmail.com,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:6849 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751088AbWHHFYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 01:24:35 -0400
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Content-Disposition: inline
In-Reply-To: <4807377b0608071709j26da1092la20f1589c7b90df7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2006 at 05:09:39PM -0700, Jesse Brandeburg (jesse.brandeburg@gmail.com) wrote:
> LPE controls whether long packet reception is permitted. Hardware
> discards long packets if LPE is 0. A long packet is one longer than
> 1522 bytes. If LPE is 1, the maximum packet size that the device can
> receive is 16384 bytes.

So there is no place at the end of skb for additional pointer.
And new question arises - until what Jesse suggested is implemented in
some way, do we need to store a pointer to shared info inside skb and
allocate it from cache in case it does no fit into aligned buffer (in
case of e1000 it happens all the time exept 1500 MTU)?
David, Herbert?

-- 
	Evgeniy Polyakov
