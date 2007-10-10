From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [IPV6] Defer IPv6 device initialization until a valid
 qdisc is specified
Date: Wed, 10 Oct 2007 12:16:42 +0900 (JST)
Message-ID: <20071010.121642.107601594.yoshfuji@linux-ipv6.org>
References: <20071009162158.f25d4fdb.mitch@linux.vnet.ibm.com>
	<E1IfQR9-0006j8-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitch@linux.vnet.ibm.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:52991 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbXJJDOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 23:14:51 -0400
In-Reply-To: <E1IfQR9-0006j8-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <E1IfQR9-0006j8-00@gondolin.me.apana.org.au> (at Wed, 10 Oct 2007 09:32:35 +0800), Herbert Xu <herbert@gondor.apana.org.au> says:

> Mitsuru Chinen <mitch@linux.vnet.ibm.com> wrote:
> > To judge the timing for DAD, netif_carrier_ok() is used. However,
> > there is a possibility that dev->qdisc stays noop_qdisc even if
> > netif_carrier_ok() returns true. In that case, DAD NS is not sent out.
> > We need to defer the IPv6 device initialization until a valid qdisc
> > is specified.
> 
> Is this really necessary?
> 
> What if this is plugged into a switch that has nothing else
> connected? Should you also wait for something to be connected
> to the switch?

While MLD, DAD (and RS) packets must be observed on the wire
outside the box, we've been observing random "failures" with
our test system due to this bug.
The bug results in failures of detecting duplicate address (our side and
the other side afterwards), and of having valid global address(es).

Even in practical system, a box sometimes fail to have valid global
address for 10 minutes or so, which is not good.  if MLD snooping is
supported and enabled on the switch, we may fail to insist our address
is already in-use against DAD from other node.

We'd really like to do our best to avoid such random failures
even if it may/can not be perfect.

Regards,

--yoshfuji
