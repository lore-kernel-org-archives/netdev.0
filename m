From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] stmmac: Don't init ptp again when resume from
 suspend/hibernation
Date: Mon, 22 Dec 2014 15:42:39 -0500 (EST)
Message-ID: <20141222.154239.1266616420580493079.davem@davemloft.net>
References: <1418999898-10298-1-git-send-email-chenhc@lemote.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, srinivas.kandagatla@st.com,
	netdev@vger.kernel.org
To: chenhc@lemote.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43196 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755471AbaLVUml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 15:42:41 -0500
In-Reply-To: <1418999898-10298-1-git-send-email-chenhc@lemote.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huacai Chen <chenhc@lemote.com>
Date: Fri, 19 Dec 2014 22:38:18 +0800

> Both stmmac_open() and stmmac_resume() call stmmac_hw_setup(), and
> stmmac_hw_setup() call stmmac_init_ptp() unconditionally. However, only
> stmmac_release() calls stmmac_release_ptp(). Since stmmac_suspend()
> doesn't call stmmac_release_ptp(), stmmac_resume() also needn't call
> stmmac_init_ptp().
> 
> This patch also fix a "scheduling while atomic" problem when resume
> from suspend/hibernation. Because stmmac_init_ptp() will trigger
> scheduling while stmmac_resume() hold a spinlock.
> 
> Callgraph of "scheduling while atomic":
> stmmac_resume() --> stmmac_hw_setup() --> stmmac_init_ptp() -->
> stmmac_ptp_register() --> ptp_clock_register() --> device_create() -->
> device_create_groups_vargs() --> device_add() --> devtmpfs_create_node()
> --> wait_for_common() --> schedule_timeout() --> __schedule()
> 
> Signed-off-by: Huacai Chen <chenhc@lemote.com>

Applied, thank you.
