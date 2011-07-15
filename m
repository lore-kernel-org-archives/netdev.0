From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: do not start the interface if reset fails
Date: Thu, 14 Jul 2011 17:06:02 -0700 (PDT)
Message-ID: <20110714.170602.913766899003751061.davem@davemloft.net>
References: <1310579690-24622-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56885 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932359Ab1GOAGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 20:06:07 -0400
In-Reply-To: <1310579690-24622-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Wed, 13 Jul 2011 14:54:50 -0300

> When bnx2_reset_task() is called, it will stop,
> (re)initialize and start the interface to restore
> the working condition.
> 
> The bnx2_init_nic() calls bnx2_reset_nic() which will
> reset the chip and then call bnx2_free_skbs() to free
> all the skbs.
> 
> The problem happens when bnx2_init_chip() fails because
> bnx2_reset_nic() will just return skipping the ring
> initializations at bnx2_init_all_rings(). Later, the
> reset task starts the interface again and the system
> crashes due a NULL pointer access (no skb in the ring).
> 
> This patch just check the return code and if an error is
> reported, warn the user and abort. It's better to have a
> non working interface than a crash.
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>

Broadcom folks?
