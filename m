From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] team: avoid possible underflow of count_pending
 value for notify_peers and mcast_rejoin
Date: Wed, 14 Jan 2015 16:55:09 -0500 (EST)
Message-ID: <20150114.165509.1466571325244320266.davem@davemloft.net>
References: <1421255730-10681-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbenc@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45720 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752382AbbANVzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 16:55:12 -0500
In-Reply-To: <1421255730-10681-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 14 Jan 2015 18:15:30 +0100

> This patch is fixing a race condition that may cause setting
> count_pending to -1, which results in unwanted big bulk of arp messages
> (in case of "notify peers").
> 
> Consider following scenario:
 ...
> Fix this race by using atomic_dec_if_positive - that will prevent
> count_pending running under 0.
> 
> Fixes: fc423ff00df3a1955441 ("team: add peer notification")
> Fixes: 492b200efdd20b8fcfd  ("team: add support for sending multicast rejoins")
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied, thanks.

I am assuming that v3.12 and later need this fix, therefore I'm queueing it up for
-stable.
