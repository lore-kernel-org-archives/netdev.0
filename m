From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.23-rc5] ipsec interfamily route handling fix
Date: Wed, 12 Sep 2007 05:46:56 -0700 (PDT)
Message-ID: <20070912.054656.102561172.davem@davemloft.net>
References: <200709061900.10508.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joakim.koskela@hiit.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:52897
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S967513AbXILMrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 08:47:00 -0400
In-Reply-To: <200709061900.10508.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joakim Koskela <joakim.koskela@hiit.fi>
Date: Thu, 6 Sep 2007 19:00:10 +0300

> This patch addresses a couple of issues related to interfamily ipsec
> modes. The problem is that the structure of the routing info changes
> with the family during the __xfrmX_bundle_create, which hasn't been
> taken properly into account. Seems that by coincidence it hasn't
> caused problems on 32bit platforms, but crashes for example on x86_64
> in 6-4 around line 209 of xfrm6_policy.c as rt doesn't point to a
> rt6_info anymore, but actually a struct rtable. With 64bit pointers,
> the rt->rt6i_node pointer seems to hit something usually not null in
> the rtable that rt now points to, making it go for the path_cookie
> assignment and subsequently crashing.
> 
> Tested on both 32/64bit with all four (44/46/64/66) combinations of
> transformation. I'm still a bit worried about how for example nested
> transformations work with all of this and would appreciate if someone
> more familiar with the details of these structs could comment.
> 
> Signed-off-by: Joakim Koskela <jookos@gmail.com>

This fix basically looks fine to me, but I'd like at least one
other person to review it too.
