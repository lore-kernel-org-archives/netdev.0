From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: set carrier off in probe
Date: Fri, 30 Oct 2009 11:20:51 -0700 (PDT)
Message-ID: <20091030.112051.20510373.davem@davemloft.net>
References: <20091030155420.GA8345@gondor.apana.org.au>
	<20091030.111027.234994529.davem@davemloft.net>
	<20091030181632.GA9530@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bphilips@suse.de, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38789
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932721AbZJ3SU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 14:20:27 -0400
In-Reply-To: <20091030181632.GA9530@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 30 Oct 2009 14:16:32 -0400

> On Fri, Oct 30, 2009 at 11:10:27AM -0700, David Miller wrote:
> . 
>> Because the driver must start in state with carrier off anyways,
>> so that we get the transition event when the device comes up
>> from link down to link up.
> 
> Well we want all drivers to start in state NOCARRIER.  However,
> a freshly allocated netdev has the NOCARRIER bit off.  This means
> every single driver has to set the NOCARRIER bit.
> 
> It would seem much easier to ensure that the NOCARRIER bit is set
> in a newly allocated netdev.

Since many drivers (especially virtual software ones) do not manage
carrier state and therefore that's why we start in state carrier on.

We've had this discussion a few times before, most recently with
Rusty wrt. virtio :-)
