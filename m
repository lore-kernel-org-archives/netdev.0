From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wan: dscc4: use msecs_to_jiffies for conversions
Date: Sun, 07 Jun 2015 00:13:51 -0700 (PDT)
Message-ID: <20150607.001351.1615444562432115091.davem@davemloft.net>
References: <1433580066-1237-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hofrat@osadl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39386 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbbFGHNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 03:13:52 -0400
In-Reply-To: <1433580066-1237-1-git-send-email-hofrat@osadl.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicholas Mc Guire <hofrat@osadl.org>
Date: Sat,  6 Jun 2015 10:41:06 +0200

> API compliance scanning with coccinelle flagged:
> ./drivers/net/wan/dscc4.c:1036:1-33:
>         WARNING: timeout (10) seems HZ dependent
> ./drivers/net/wan/dscc4.c:554:2-34:
>         WARNING: timeout (10) seems HZ dependent
> ./drivers/net/wan/dscc4.c:599:2-34:
>         WARNING: timeout (10) seems HZ dependent
> 
> Numeric constants passed to schedule_timeout_*() make the effective
> timeout HZ dependent which does not seem to be the intent here.
> Fixed up by converting the constant to jiffies with msecs_to_jiffies()
> 
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Whoever wrote these things probably wanted whatever this amounts
to when HZ=100, so that is the only valid transformation you can
make to fix this up here.

Otherwise you seriously risk breaking the driver.
