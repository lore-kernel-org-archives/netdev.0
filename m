From: David Miller <davem@davemloft.net>
Subject: Re: tcp congestion policy selection link order fragile
Date: Mon, 18 Sep 2006 07:06:00 -0700 (PDT)
Message-ID: <20060918.070600.107685035.davem@davemloft.net>
References: <20060917122153.GA2932@outpost.ds9a.nl>
	<20060918.015130.34760190.davem@davemloft.net>
	<20060918095936.GA6161@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:52153
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751668AbWIROGM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 10:06:12 -0400
To: bert.hubert@netherlabs.nl
In-Reply-To: <20060918095936.GA6161@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: bert hubert <bert.hubert@netherlabs.nl>
Date: Mon, 18 Sep 2006 11:59:36 +0200

> I've tested this patch and it does the job for me, reno is now the default,
> even when more advanced options are compiled in, but the rest is still
> available.

This breaks our intention that when TCP_CONG_ADVANCED is not set, BIC
is the default since that is the default congestion control algorithm
we want users to get.

When TCP_CONG_ADVANCED is disabled, we turn on TCP_CONG_BIC,
and your changes cause reno to be the default algorithm in
that build case.  That's not what we want.

Any ordering scheme is wrong or unexpected for _somebody_.  Look how
easy it was for you to break the BIC default we had in place.  To make
things sensible for you, your patch causes everyone else got the wrong
default.  Therefore any ordering scheme is by definition arbitrary and
no ordering is better than any other one.
