From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Resurrect napi_poll patch.
Date: Fri, 20 Jul 2007 23:00:50 -0700 (PDT)
Message-ID: <20070720.230050.104035394.davem@davemloft.net>
References: <20070720.223129.59470764.davem@davemloft.net>
	<46A19DBF.6030902@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	rusty@rustcorp.com.au, jgarzik@pobox.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52069
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932906AbXGUGAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 02:00:51 -0400
In-Reply-To: <46A19DBF.6030902@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Sat, 21 Jul 2007 07:46:39 +0200

> I believe the compat attribute should work fine. One thing thing
> that is not explicitly supported as datatype, but works fine, is
> lists of attributes (using nla_for_each_attr), which looks like a
> good match for this case. But I think its questionable whether we
> should put any effort in NAPI rtnetlink support. It seems to driver
> specific for rtnetlink to me, and I'm not aware of any user of this.
> Ethtool might have its own compatibility issues, I'm not sure, but
> I don't think it would hurt to simply remove it from rtnetlink.

Another idea is to allow the driver to decide what to do with the
value.

The driver will have to be involved anyways in order to iterate over
the per-netdev NAPI objects.

So, for example, one driver might take the given weight and distribute
it evenly amongst the RX queues it has.

Trying to let netlink set things on a per-queue basis is indeed
cumbersom and not worth doing at all in my opinion.  I however think
it's not a bad idea to keep the unary weight setting around and
let the driver figure out what to do with it in the multi-queue
case.

