From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] net/ehea: bitops work on unsigned longs
Date: Wed, 31 Dec 2008 20:02:51 +1100
Message-ID: <1230714172.15389.63.camel@pasglop>
References: <20081231141853.c6d123c4.sfr@canb.auug.org.au>
	 <20081230.215156.151347026.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, tklein@de.ibm.com, netdev@vger.kernel.org,
	raisch@de.ibm.com, themann@de.ibm.com, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:53807 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752296AbYLaJDe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Dec 2008 04:03:34 -0500
In-Reply-To: <20081230.215156.151347026.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-12-30 at 21:51 -0800, David Miller wrote:
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Wed, 31 Dec 2008 14:18:53 +1100
> 
> > These changes will avoid several warnings when we change u64 to unsigned
> > long long.
> > 
> > Also, ehea_driver_flags is only used in ehca_main.c
> > 
> > Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> > ---
> 
> And also rejected, just like the previous two.
> 
> This is so much worse than the problems we had with
> printing u64's and it's being done as a result to
> the "fix" for that.

Hi David !

I think this patch specifically is different and deserve a second look.

While the other patches are somewhat debatable (I do agree with you for
example that we shouldn't break the possibility of building for 32-bit,
and we shouldn't artifically add crud to silence warnings caused by the
u64 type change etc... I'll send separate replies to the other messages
later), in the case of this specific patch, I think it's actually more
correct to define a "flags" field that is used by set_bit() and
test_bit() using "long" rather than "u64" (for that same reason you
mention, which is 32/64-bit compatibility).

IE. The bitops operate on longs. Thus the field should be a long,
period. The compatibility here consists of making sure we don't use bits
above 31, which in this case is find since we use a short enum.

Thus the patch is makes the code cleaner and more correct regardless of
the type change of u64.

So from my side, this patch is

Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Cheers,
Ben.


