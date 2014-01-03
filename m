From: Joe Perches <joe@perches.com>
Subject: Re: [net-next v2 03/11] ixgbe: Use static inlines instead of macros
Date: Thu, 02 Jan 2014 21:28:04 -0800
Message-ID: <1388726884.2527.4.camel@joe-AO722>
References: <1388726310-2996-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1388726310-2996-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Mark Rustad <mark.d.rustad@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0098.hostedemail.com ([216.40.44.98]:34939 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750717AbaACF2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 00:28:09 -0500
In-Reply-To: <1388726310-2996-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-02 at 21:18 -0800, Jeff Kirsher wrote:
> From: Mark Rustad <mark.d.rustad@intel.com>
[]
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
[]
> @@ -124,22 +124,31 @@ s32 ixgbe_reset_pipeline_82599(struct ixgbe_hw *hw);
>  #ifndef writeq
>  #define writeq(val, addr) writel((u32) (val), addr); \
>      writel((u32) (val >> 32), (addr + 4));
>  #endif

This is unchanged, but it would be nicer with a do {} while.

#ifndef writeq
#define writeq(val, addr)				\
do {							\
	writel((u32)(val), addr);			\
	writel((u32)((val) >> 32), (addr + 4));		\
} while (0)

Even then, this could be nicer as an inline too.
