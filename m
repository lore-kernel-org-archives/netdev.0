From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 2/6] bnx2x: prevent statistics update flow to
 act before statistics are started
Date: Wed, 17 Jul 2013 18:17:47 -0700 (PDT)
Message-ID: <20130717.181747.1265135119980557818.davem@davemloft.net>
References: <1374098440-27877-1-git-send-email-dmitry@broadcom.com>
	<1374098440-27877-3-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55883 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756379Ab3GRBRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 21:17:48 -0400
In-Reply-To: <1374098440-27877-3-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Thu, 18 Jul 2013 01:00:36 +0300

> @@ -1830,6 +1830,7 @@ struct bnx2x {
>  
>  	int fp_array_size;
>  	u32 dump_preset_idx;
> +	atomic_t				stats_started;

The only uses of those stats_started member are with atomic_set()
and atomic_read(), neither of which are atomic operations.

If there is existing locking which protects this value, then
a simple "bool stats_started;" would work.

Otherwise, you'll need to use an "unsigned long" set of atomic
bits and operations such as test_and_set_bit().
