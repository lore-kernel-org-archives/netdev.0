From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8152: correct error returns
Date: Mon, 04 Aug 2014 15:18:27 -0700 (PDT)
Message-ID: <20140804.151827.179999106523102125.davem@davemloft.net>
References: <1406901370-6847-1-git-send-email-oneukum@suse.de>
	<20140802.163418.1314777407262254543.davem@davemloft.net>
	<1407049618.26893.8.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com
To: oneukum@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46658 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752354AbaHDWS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 18:18:29 -0400
In-Reply-To: <1407049618.26893.8.camel@linux-fkkt.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.de>
Date: Sun, 03 Aug 2014 09:06:58 +0200

> OK, I just looked at this single driver. I'll try to come up with
> a generic solution. The mapping is a bit simplistic. I should let
> -ENOMEM pass for example.

And the problem also isn't limited USB networking drivers, just
about every driver I looked at passed these autopm errors right
back to userspace.

Largely people just call the autopm interfaces and propagate any
errors they get.  So you probably want to put the translator/filter
there.

But of course, that doesn't handle the non-autopm code paths into the
PM layer that can end up in this situation.
