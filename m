From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tg3: Override clock, link aware and link idle
 mode during NVRAM dump
Date: Sat, 24 May 2014 00:17:39 -0400 (EDT)
Message-ID: <20140524.001739.1276621872731687446.davem@davemloft.net>
References: <1400864084-27118-1-git-send-email-prashant@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: prashant@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58229 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbaEXERl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 00:17:41 -0400
In-Reply-To: <1400864084-27118-1-git-send-email-prashant@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prashant Sreedharan <prashant@broadcom.com>
Date: Fri, 23 May 2014 09:54:44 -0700

> +		if (cpmu_val & (CPMU_CTRL_LINK_AWARE_MODE |
> +				CPMU_CTRL_LINK_IDLE_MODE)) {
> +

Please remove this empty line.

> +			tw32(TG3_CPMU_CTRL, cpmu_val &
> +			     ~(CPMU_CTRL_LINK_AWARE_MODE |
> +			       CPMU_CTRL_LINK_IDLE_MODE));

This is not indented correctly.

The ~() expression is part of the "cpum_val &", it's not
another separate argument to tw32().

Therefore ~() should be indented to the column cpum_val starts
at.

> +		if (need_resched()) {
> +			if (signal_pending(current)) {
> +				eeprom->len += i;
> +				ret = -EINTR;
> +				goto eeprom_done;

Why are you incrementing eeprom->len when you break out of the
loop due to a signal?  You didn't read that extra byte.
