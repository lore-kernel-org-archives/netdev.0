From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 40/44] [XFRM] POLICY: sub policy support.
Date: Wed, 23 Aug 2006 22:48:00 -0700 (PDT)
Message-ID: <20060823.224800.124082063.davem@davemloft.net>
References: <11563453671463-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453672872-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453671273-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:65153
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030307AbWHXFr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 01:47:57 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453671273-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:41 +0900

> Sub policy is introduced. Main and sub policy are applied the same flow.
> (Policy that current kernel uses is named as main.)
> It is required another transformation policy management to keep IPsec
> and Mobile IPv6 lives separate.
> Policy which lives shorter time in kernel should be a sub i.e. normally
> main is for IPsec and sub is for Mobile IPv6.
> (Such usage as two IPsec policies on different database can be used, too.)
> 
> Limitation or TODOs:
>  - Sub policy is not supported for per socket one (it is always inserted as main).
>  - Current kernel makes cached outbound with flowi to skip searching database.
>    However this patch makes it disabled only when "two policies are used and
>    the first matched one is bypass case" because neither flowi nor bundle
>    information knows about transformation template size.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19

Those socket policies are becomming more and more difficult to
deal with.  I like them as a feature, but I wonder who uses
them :-)  They do not live in the flow cache so they hurt
performance until we find a way to place them there.  Perhaps
we can extend the flow keying somehow to account for socket
based policies in the flow cache.


