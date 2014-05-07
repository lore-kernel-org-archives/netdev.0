From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net] be2net: Poll for link status till 5s in ethtool
 diag test
Date: Wed, 07 May 2014 16:14:19 -0400 (EDT)
Message-ID: <20140507.161419.1323992216609425261.davem@redhat.com>
References: <20140505232014.GA27648@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajit.khaparde@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45938 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750966AbaEGUOW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2014 16:14:22 -0400
In-Reply-To: <20140505232014.GA27648@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajit.khaparde@emulex.com>
Date: Mon, 5 May 2014 18:20:14 -0500

> After the loopback test is finished,
> it takes a few seconds for link to come back up.
> Poll for link status every 1 second interval for 5 seconds, only in cases
> when the link was UP before PHY loopback test was issued.
> 
> Signed-off-by: Suresh Reddy <suresh.reddy@emulex.com>
> Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>

This is really anti-social, because the RTNL semaphore is held during
this entire call.

You are potentially blocking any and all network configuration setting
and fetches for up to 5 seconds.
