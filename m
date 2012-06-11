From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Reorder initialization in ip_route_output to fix
 gcc warning
Date: Mon, 11 Jun 2012 00:05:13 -0700 (PDT)
Message-ID: <20120611.000513.321754218579060771.davem@davemloft.net>
References: <1339394724-28296-1-git-send-email-roland@kernel.org>
	<20120610.234411.850948486629299757.davem@davemloft.net>
	<CAG4TOxNpw0BAWPK3Zde_mThTvY-ho+Ce_aau3DoLc-0TRFq3PQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40284 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130Ab2FKHFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 03:05:19 -0400
In-Reply-To: <CAG4TOxNpw0BAWPK3Zde_mThTvY-ho+Ce_aau3DoLc-0TRFq3PQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <roland@kernel.org>
Date: Mon, 11 Jun 2012 00:00:51 -0700

>> I can't figure out what it is actually warning about, can you?
> 
> I think gcc thinks it already initialized the __fl_common struct
> once when it hits the .flowi4_oif initializer (which expands to
> __fl_common.flowic_oif), and then having the .daddr / .saddr
> initializers makes it thinks its done with that structure.
> 
> So it thinks it's initializing __fl_common.flowic_tos to 0, and
> then the .flowi4_tos initializer comes along as a surprise.
> 
> Hmm, looks like http://gcc.gnu.org/bugzilla/show_bug.cgi?id=52880
> which is fixed after gcc 4.7.0.  I think it's probably worth working
> around this gcc issue, since this makes W=1 way noisier in
> my build.

I suspected it was a compiler bug :-)

Anyways, agreed, applied.
