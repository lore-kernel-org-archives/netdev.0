From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx5_core: Support MANAGE_PAGES and QUERY_PAGES
 firmware command changes
Date: Thu, 15 Aug 2013 01:48:37 -0700 (PDT)
Message-ID: <20130815.014837.1103024579636450520.davem@davemloft.net>
References: <1376491608-3759-1-git-send-email-moshel@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roland@kernel.org, ogerlitz@mellanox.com,
	eli@mellanox.com
To: moshel@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38014 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086Ab3HOIsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 04:48:38 -0400
In-Reply-To: <1376491608-3759-1-git-send-email-moshel@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moshe Lazer <moshel@mellanox.com>
Date: Wed, 14 Aug 2013 17:46:48 +0300

> In the previous QUERY_PAGES command version we used one command to get the
> required amount of boot, init and post init pages.  The new version uses the
> op_mod field to specify whether the query is for the required amount of boot,
> init or post init pages. In addition the output field size for the required
> amount of pages increased from 16 to 32 bits.
> 
> In MANAGE_PAGES command the input_num_entries and output_num_entries fields
> sizes changed from 16 to 32 bits and the PAS tables offset changed to 0x10.
> 
> In the pages request event the num_pages field also changed to 32 bits.
> 
> In the HCA-capabilities-layout the size and location of max_qp_mcg field has
> been changed to support 24 bits.
> 
> This patch isn't compatible with firmware versions < 5; however, it  turns out that the
> first GA firmware we will publish will not support previous versions so this should be OK.
> 
> Signed-off-by: Moshe Lazer <moshel@mellanox.com>
> Signed-off-by: Eli Cohen <eli@mellanox.com>

You're going to have to explain a few things before I'm even going to consider
applying this.

What tree are you targetting 'net' or 'net-next'?

Next, does this break things for people using older firmware?

I don't see anything that verifies that the firmware is of a version
that uses the command data structures you're changing in this patch.

If you're not checking, this is terrible, and I find it utterly
unacceptable.

You can't just go "oh the latest firmware uses this new layout, so
we don't have to consider what the older firmware wants."
