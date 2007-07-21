From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH]: Resurrect napi_poll patch.
Date: Sat, 21 Jul 2007 07:46:39 +0200
Message-ID: <46A19DBF.6030902@trash.net>
References: <20070720.223129.59470764.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	rusty@rustcorp.com.au, jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44358 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755384AbXGUFsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 01:48:13 -0400
In-Reply-To: <20070720.223129.59470764.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
[ huge patch, not looked at it :) ]

> One area for discussion is what to do about rtnetlink, it allows
> setting the dev->napi.weight, but we need to extend it so it can
> do something sane in multi-napi-per-netdev situations.


I believe the compat attribute should work fine. One thing thing
that is not explicitly supported as datatype, but works fine, is
lists of attributes (using nla_for_each_attr), which looks like a
good match for this case. But I think its questionable whether we
should put any effort in NAPI rtnetlink support. It seems to driver
specific for rtnetlink to me, and I'm not aware of any user of this.
Ethtool might have its own compatibility issues, I'm not sure, but
I don't think it would hurt to simply remove it from rtnetlink.

