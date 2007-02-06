From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH][IPSEC][0/3]inter address family ipsec tunnel
Date: Tue, 06 Feb 2007 14:24:07 -0800 (PST)
Message-ID: <20070206.142407.48395902.davem@davemloft.net>
References: <20061229144702.11ff0478.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: miika@iki.fi, Diego.Beltrami@hiit.fi, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: kazunori@miyazawa.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52230
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030188AbXBFWYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 17:24:33 -0500
In-Reply-To: <20061229144702.11ff0478.kazunori@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Date: Fri, 29 Dec 2006 14:47:02 +0900

> I fixed the compile issue when we configure IPv6 as a module.
> 
> [1/3] exporting xfrm_state_afinfo
> [2/3] supporting IPv6 over IPv4 IPsec
> [3/3] supporting IPv4 over IPv6 IPsec
> 
> These patches can be applied to linux-2.6.20-rc2.

Thank you.  This is not a bad solution to the symbol
export problem, for now.

I noticed that there is no need for the module symbol
export of xfrm6_output() you added, because xfrm6_output.o
and xfrm6_state.o always get linked together.

So I will remove that:

+EXPORT_SYMBOL(xfrm6_output);

part of the first patch.

We see so many issues with ipv6 symbols dependencies in various
subsystems (netfilter, xfrm, etc.).  It is a sign that we need
some kind of long range plan to deal with this problem.  Since
the ipv6 module can't be unloaded anyways, and it's been broken
like that forever, it might make sense to make ipv6 only available
non-modular.  I know people would dislike this, but the current
situation isn't good either.

Thanks again.

