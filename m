From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net: skb_orphan on dev_hard_start_xmit
Date: Fri, 03 Jul 2009 20:13:47 -0700 (PDT)
Message-ID: <20090703.201347.146036232.davem@davemloft.net>
References: <20090703075530.GA25190@gondor.apana.org.au>
	<20090703.200254.172991821.davem@davemloft.net>
	<20090704030830.GA32442@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, patrick.ohly@intel.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	divy@chelsio.com, rolandd@cisco.com, xemul@openvz.org,
	dcbw@redhat.com, libertas-dev@lists.infradead.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34691
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752824AbZGDDNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 23:13:41 -0400
In-Reply-To: <20090704030830.GA32442@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 4 Jul 2009 11:08:30 +0800

> On Fri, Jul 03, 2009 at 08:02:54PM -0700, David Miller wrote:
>>
>> In particular the case of handling a device without usable TX
>> completion event indications is still quite troublesome.
> e
> Which particular devices do you have in mind?

NIU

I basically can't defer interrupts because the chip supports
per-TX-desc interrupt indications but it lacks an "all TX queue sent"
event.  So if, say, tell it to interrupt every 1/4 of the TX queue
then up to 1/4 of the queue can have packets "stuck" in there
if TX activity all of a sudden ceases.

The only thing I've come up with to be able to mitigate interrupts is
to use an hrtimer of some sort.  But that's going to be hard to get
right, and who knows what kind of latencies will be introduced for TX
completion packet freeing unless I am very carefull.

And finally this belongs in generic code, not in the NIU driver,
whatever we come up with.  Especially since my understanding is that
this is similar to what Rusty needs.

