From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC] xfrm_state locking problem in xfrm_input.c
Date: Mon, 11 May 2009 22:07:23 -0700 (PDT)
Message-ID: <20090511.220723.266123145.davem@davemloft.net>
References: <20090511184739.6e497f29@penta.localdomain>
	<20090512034813.GA25841@gondor.apana.org.au>
	<20090512000516.32589e1f@penta.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: ypolyans@Princeton.EDU
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43721
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751803AbZELFH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 01:07:26 -0400
In-Reply-To: <20090512000516.32589e1f@penta.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yury Polyanskiy <ypolyans@Princeton.EDU>
Date: Tue, 12 May 2009 00:05:16 -0400

> On Tue, 12 May 2009 13:48:13 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
>> On Mon, May 11, 2009 at 06:47:39PM -0400, Yury Polyanskiy wrote:
>> > xfrm_input() code uses spin_lock() where it must be using
>> > spin_lock_bh() instead. The corresponding code in xfrm_output.c
>> > correctly uses spin_lock_bh(). 
>> > 
>> > Note that if the locally generated packet is sent to a local ip,
>> > dev_queue_xmit() calls loopback_xmit() and the xfrm_input() will be
>> > called with softirqs enabled.
>> 
>> dev_queue_xmit always disables BH before calling the device xmit
>> function.  So how can this happen?
>> 
> 
> Oops, you right. Thanks for the explanation!

So you didn't actually hit a bug that led you to write that
patch?

Please state this explicitly next time, and tell us that you are
"fixing" something based purely upon code inspection rather than
hitting a bug yourself.
