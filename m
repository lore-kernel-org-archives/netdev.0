From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 05/10] be2net: don't enable PAUSE by default
Date: Mon, 04 May 2015 11:59:57 -0400 (EDT)
Message-ID: <20150504.115957.2215135038852456749.davem@davemloft.net>
References: <1430722042-26449-1-git-send-email-sathya.perla@emulex.com>
	<1430722042-26449-6-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36392 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428AbbEDP76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 11:59:58 -0400
In-Reply-To: <1430722042-26449-6-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Mon,  4 May 2015 02:47:17 -0400

> From: Kalesh AP <kalesh.purayil@emulex.com>
> 
> The driver so far, on load, always tried to enable RX/TX general pause.
> This setting always fails on certain profiles (like FCoE) where PFC is
> needed. Such failures cannot be effectively communicated to the stack or
> user. To fix this unpredictability in state, this patch changes the driver
> behavior by not configuring pause at load time.
> The user can configure it via ethtool and if the setting is disallowed,
> an appropriate error is returned.
> 
> Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Not enabling pause by default is going to be _STRONGLY_ not expected
by the user and will cause unwanted packet drops in high traffic
environments.

It's not the user's fault that your stuff is architected in such a way
such that handling this properly isn't easy.
