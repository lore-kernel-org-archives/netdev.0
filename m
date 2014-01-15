From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [net-next v4 3/7] ixgbe: Use static inlines instead of macros
Date: Wed, 15 Jan 2014 16:16:55 +0000
Message-ID: <8B167AFF-755D-4389-BF31-69A6175B7B76@intel.com>
References: <1389754397-2507-1-git-send-email-aaron.f.brown@intel.com>
 <1389754397-2507-4-git-send-email-aaron.f.brown@intel.com>
 <1389755839.14001.6.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Brown, Aaron F" <aaron.f.brown@intel.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41392 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751499AbaAOQRR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 11:17:17 -0500
In-Reply-To: <1389755839.14001.6.camel@joe-AO722>
Content-Language: en-US
Content-ID: <AB99E00952FACD499CAFFB6C58395D44@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 14, 2014, at 7:17 PM, Joe Perches <joe@perches.com> wrote:

> On Tue, 2014-01-14 at 18:53 -0800, Aaron Brown wrote:
>> From: Mark Rustad <mark.d.rustad@intel.com>
> 
> trivia:
> 
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
> []
>> @@ -124,24 +124,40 @@ s32 ixgbe_reset_pipeline_82599(struct ixgbe_hw *hw);
> []
>> -#define IXGBE_WRITE_REG(a, reg, value) writel((value), ((a)->hw_addr + (reg)))
>> +static inline void ixgbe_write_reg(struct ixgbe_hw *hw, u32 reg, u32 value)
>> +{
>> +	writel(value, hw->hw_addr + reg);
>> +}
>> +#define IXGBE_WRITE_REG(a, reg, value) ixgbe_write_reg((a), (reg), (value))
> 
> There's no real value in adding parentheses to these macros.

I suppose that is true in this case. I have it so ingrained to always put parens around the macro parameter references, that I just automatically do it. Still, it makes it safer for any future changes, though the most likely next change here will be deletion anyway. :-)

-- 
Mark Rustad, Networking Division, Intel Corporation
