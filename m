From: Joe Perches <joe@perches.com>
Subject: Re: [net-next v4 3/7] ixgbe: Use static inlines instead of macros
Date: Tue, 14 Jan 2014 19:17:19 -0800
Message-ID: <1389755839.14001.6.camel@joe-AO722>
References: <1389754397-2507-1-git-send-email-aaron.f.brown@intel.com>
	 <1389754397-2507-4-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Mark Rustad <mark.d.rustad@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Aaron Brown <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0061.hostedemail.com ([216.40.44.61]:51234 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750928AbaAODRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 22:17:25 -0500
In-Reply-To: <1389754397-2507-4-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-14 at 18:53 -0800, Aaron Brown wrote:
> From: Mark Rustad <mark.d.rustad@intel.com>

trivia:

> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
[]
> @@ -124,24 +124,40 @@ s32 ixgbe_reset_pipeline_82599(struct ixgbe_hw *hw);
[]
> -#define IXGBE_WRITE_REG(a, reg, value) writel((value), ((a)->hw_addr + (reg)))
> +static inline void ixgbe_write_reg(struct ixgbe_hw *hw, u32 reg, u32 value)
> +{
> +	writel(value, hw->hw_addr + reg);
> +}
> +#define IXGBE_WRITE_REG(a, reg, value) ixgbe_write_reg((a), (reg), (value))

There's no real value in adding parentheses to these macros.
