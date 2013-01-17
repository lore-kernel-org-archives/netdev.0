From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/xfrm/xfrm_replay: avoid division by zero
Date: Thu, 17 Jan 2013 15:46:22 -0500 (EST)
Message-ID: <20130117.154622.1758706863368180089.davem@davemloft.net>
References: <1358449108-67839-1-git-send-email-nickolai@csail.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: nickolai@csail.mit.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358449108-67839-1-git-send-email-nickolai@csail.mit.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nickolai Zeldovich <nickolai@csail.mit.edu>
Date: Thu, 17 Jan 2013 13:58:28 -0500

> All of the xfrm_replay->advance functions in xfrm_replay.c check if
> x->replay_esn->replay_window is zero (and return if so).  However,
> one of them, xfrm_replay_advance_bmp(), divides by that value (in the
> '%' operator) before doing the check, which can potentially trigger
> a divide-by-zero exception.  Some compilers will also assume that the
> earlier division means the value cannot be zero later, and thus will
> eliminate the subsequent zero check as dead code.
> 
> This patch moves the division to after the check.
> 
> Signed-off-by: Nickolai Zeldovich <nickolai@csail.mit.edu>

I'm assuming Steffen will take care of this patch.
