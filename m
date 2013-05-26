From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ARM: kirkwood: proper retain MAC address
 workaround on DT ethernet
Date: Sat, 25 May 2013 21:04:41 -0700 (PDT)
Message-ID: <20130525.210441.818472895703230779.davem@davemloft.net>
References: <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
	<1369253042-15082-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, jason@lakedaemon.net, andrew@lunn.ch,
	benh@kernel.crashing.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43361 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714Ab3EZEEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 May 2013 00:04:47 -0400
In-Reply-To: <1369253042-15082-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Date: Wed, 22 May 2013 22:04:01 +0200

> +			memcpy((void *)p->value, reg, 6);

This cast is completely unnecessary, non-void to void pointer casts
are automatic.

If it is necessary, because p->value is const, then you are trying
to change something behind the OF layer's back and need to use
the appropriate interface to change the property contents.
