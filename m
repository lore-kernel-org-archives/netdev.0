From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 03/12] e1000e: add check on e1e_wphy() return value
Date: Thu, 10 Aug 2017 10:56:52 -0700
Message-ID: <1502387812.2219.44.camel@perches.com>
References: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
         <20170809214746.28139-4-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Gustavo A R Silva <garsilva@embeddedor.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0009.hostedemail.com ([216.40.44.9]:42720 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752756AbdHJR44 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 13:56:56 -0400
In-Reply-To: <20170809214746.28139-4-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-08-09 at 14:47 -0700, Jeff Kirsher wrote:
> From: Gustavo A R Silva <garsilva@embeddedor.com>
> 
> Check return value from call to e1e_wphy(). This value is being
> checked during previous calls to function e1e_wphy() and it seems
> a check was missing here.

The use of "it seems" here is less than compelling.

Perhaps the write of 0x3140 to MII_BMCR takes too long for
the return value used.

Many other uses of e1e_wphy.*MII_BMCR are also not checked.

For instance: the e100e/ethtool uses.

> diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
[]
> @@ -2437,6 +2437,8 @@ static s32 e1000_hv_phy_workarounds_ich8lan(struct e1000_hw *hw)
>  		if (hw->phy.revision < 2) {
>  			e1000e_phy_sw_reset(hw);
>  			ret_val = e1e_wphy(hw, MII_BMCR, 0x3140);
> +			if (ret_val)
> +				return ret_val;
>  		}
>  	}
>  
