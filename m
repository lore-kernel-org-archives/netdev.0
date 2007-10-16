From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/RFC] net: Add __napi_sycnhronize() to sync with napi
 poll
Date: Tue, 16 Oct 2007 00:44:34 -0700 (PDT)
Message-ID: <20071016.004434.106264901.davem@davemloft.net>
References: <E1IhfZr-0002FE-00@gondolin.me.apana.org.au>
	<1192520223.7205.5.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, rdreier@cisco.com, linuxppc-dev@ozlabs.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51667
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764532AbXJPHo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 03:44:29 -0400
In-Reply-To: <1192520223.7205.5.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 16 Oct 2007 17:37:03 +1000

> 
> On Tue, 2007-10-16 at 14:06 +0800, Herbert Xu wrote:
> > Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> > >
> > > Note: I use msleep_interruptible(1); just like napi_disable(). However
> > > I'm not too happy that the "hot" loop that results of a pending signal
> > > here will spin without even a cpu_relax ... what do you guys think would
> > > be the best way to handle this ?
> > 
> > Well since the loop does not check signals at all, it should
> > just use msleep.
> > 
> > Granted the process will end up in the D state and contribute
> > to the load average.  But if this loop executes long enough
> > for that to be noticed then we've got bigger problems to worry
> > about.
> 
> If Dave & Stephen agree, I'll send a patch changing napi_disable() too
> then.

I agree with the msleep() change.
