From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] Configure bridge FDB ageing time using
 netlink.
Date: Sun, 15 Mar 2015 22:13:12 -0400 (EDT)
Message-ID: <20150315.221312.1089494260964314644.davem@davemloft.net>
References: <1426297229-21122-1-git-send-email-siva.mannem.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: siva.mannem.lnx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53201 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbbCPCNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 22:13:14 -0400
In-Reply-To: <1426297229-21122-1-git-send-email-siva.mannem.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Siva Mannem <siva.mannem.lnx@gmail.com>
Date: Sat, 14 Mar 2015 07:10:29 +0530

> This patch allows user to configure bridge's FDB ageing using
> netlink(for ex, iproute2). Allowed range is 10 seconds to 1000000 seconds
> as per ieee8021QBridgeFdbAgingTime.
> 
> Signed-off-by: Siva Mannem <siva.mannem.lnx@gmail.com>

The behavior of br_changelink() leaves a lot to be desired, and this
change is making it worse.

The range of the netlink attributes, the only thing that can cause
an error, should be validated for all attributes _first_.

Because right now you can have several values change state,
then the last one has a range error, and an error is returned
without rolling back the state.

This is terrible.

When this happens the user has not reliable way to figure out
that some of the state changes it requested happened, and
exactly which ones those were.

If an error is thrown we _MUST_ not make any state changes to
the bridge whatsoever.
