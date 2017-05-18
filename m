From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [net-intel-i40e] question about assignment overwrite
Date: Thu, 18 May 2017 12:44:06 -0500
Message-ID: <20170518124406.Horde.V0ka_TqBLXCDelD3FThBIE6@gator4166.hostgator.com>
References: <20170517154858.Horde.xMvsIEhHNSGu52mfyp7HA3R@gator4166.hostgator.com>
 <1495086551.46489.1.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Content-Transfer-Encoding: 8bit
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway31.websitewelcome.com ([192.185.143.46]:31483 "EHLO
        gateway31.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756685AbdERRoM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 13:44:12 -0400
Received: from cm2.websitewelcome.com (cm2.websitewelcome.com [192.185.178.13])
        by gateway31.websitewelcome.com (Postfix) with ESMTP id 258F26805EA
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 12:44:08 -0500 (CDT)
In-Reply-To: <1495086551.46489.1.camel@intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

Quoting Jeff Kirsher <jeffrey.t.kirsher@intel.com>:

> On Wed, 2017-05-17 at 15:48 -0500, Gustavo A. R. Silva wrote:
>> While looking into Coverity ID 1408956 I ran into the following
>> piece  
>> of code at drivers/net/ethernet/intel/i40e/i40e_main.c:8807:
>>
>> 8807        if (pf->hw.mac.type == I40E_MAC_X722) {
>> 8808                pf->flags |= I40E_FLAG_RSS_AQ_CAPABLE
>> 8809                             | I40E_FLAG_128_QP_RSS_CAPABLE
>> 8810                             | I40E_FLAG_HW_ATR_EVICT_CAPABLE
>> 8811                             | I40E_FLAG_OUTER_UDP_CSUM_CAPABLE
>> 8812                             | I40E_FLAG_WB_ON_ITR_CAPABLE
>> 8813                             |
>> I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE
>> 8814                             | I40E_FLAG_NO_PCI_LINK_CHECK
>> 8815                             | I40E_FLAG_USE_SET_LLDP_MIB
>> 8816                             | I40E_FLAG_GENEVE_OFFLOAD_CAPABLE
>> 8817                             | I40E_FLAG_PTP_L4_CAPABLE
>> 8818                             | I40E_FLAG_WOL_MC_MAGIC_PKT_WAKE;
>> 8819        } else if ((pf->hw.aq.api_maj_ver > 1) ||
>> 8820                   ((pf->hw.aq.api_maj_ver == 1) &&
>> 8821                    (pf->hw.aq.api_min_ver > 4))) {
>> 8822                /* Supported in FW API version higher than 1.4 */
>> 8823                pf->flags |= I40E_FLAG_GENEVE_OFFLOAD_CAPABLE;
>> 8824                pf->flags = I40E_FLAG_HW_ATR_EVICT_CAPABLE;
>> 8825        } else {
>> 8826                pf->flags = I40E_FLAG_HW_ATR_EVICT_CAPABLE;
>> 8827        }
>>
>> The issue here is that the assignment at line 8823 is overwritten
>> by  
>> the code at line 8824.
>>
>> I'm suspicious that line 8824 should be remove and a patch like the  
>> following can be applied:
>>
>> index d5c9c9e..48ffa73 100644
>> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
>> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> @@ -8821,7 +8821,6 @@ static int i40e_sw_init(struct i40e_pf *pf)
>>                      (pf->hw.aq.api_min_ver > 4))) {
>>                  /* Supported in FW API version higher than 1.4 */
>>                  pf->flags |= I40E_FLAG_GENEVE_OFFLOAD_CAPABLE;
>> -               pf->flags = I40E_FLAG_HW_ATR_EVICT_CAPABLE;
>>          } else {
>>                  pf->flags = I40E_FLAG_HW_ATR_EVICT_CAPABLE;
>>          }
>>
>> What do you think?
>
> This issue is already fixed in my dev-queue branch on my next-queue
> tree.

Great, it's good to know.

Thanks!
