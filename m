From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Revert "net/ipv6: add sysctl option
 accept_ra_min_hop_limit"
Date: Wed, 02 Sep 2015 16:11:10 -0700 (PDT)
Message-ID: <20150902.161110.223512323094619164.davem@davemloft.net>
References: <20150902094301.GA6434@via.ecp.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, liuhangbin@gmail.com,
	hideaki.yoshifuji@miraclelinux.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39939 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752666AbbIBXLL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 19:11:11 -0400
In-Reply-To: <20150902094301.GA6434@via.ecp.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Wed, 2 Sep 2015 11:43:01 +0200

> This reverts commit 8013d1d7eafb0589ca766db6b74026f76b7f5cb4.
> 
> There are several issues with this patch.
> It completely cancels the security changes introduced by 6fd99094de2b
> ("ipv6: Don't reduce hop limit for an interface").
> The current default value (min hop limit = 1) can result in the same
> denial of service that 6fd99094de2b prevents, but it is hard to define
> a correct and sane default value.
> More generally, it is yet another IPv6 sysctl, and we already have too
> many.
> 
> This was introduced to satisfy a TAHI test case which, in my opinion, is
> too strict, turning the RFC's "SHOULD" into a "MUST":
> 
>     If the received Cur Hop Limit value is non-zero, the host
>     SHOULD set its CurHopLimit variable to the received value.
> 
> The behavior of this sysctl is wrong in multiple ways.  Some are
> fixable, but let's not rush this commit into mainline, and revert this
> while we still can, then we can come up with a better solution.
> 
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

I don't agree with this revert.

If you look at the original commit, the quoted RFC recommends adding
a configurable method to protect against this.

And that's exactly what the commit you are trying to revert is doing.

The only thing I would entertain is potentially an adjustment of the
default, working in concert with the TAHI folks to make sure their
tests still pass with any new default.

Thanks.
