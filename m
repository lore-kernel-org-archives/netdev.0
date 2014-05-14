From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [net-next 01/11] ixgbe: fix detection of SFP+ capable interfaces
Date: Wed, 14 May 2014 18:22:20 +0000
Message-ID: <87618083B2453E4A8714035B62D679924FF674A6@FMSMSX105.amr.corp.intel.com>
References: <1400057663-4578-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1400057663-4578-2-git-send-email-jeffrey.t.kirsher@intel.com>
 <537360F3.9000000@cogentembedded.com>
 <87618083B2453E4A8714035B62D679924FF672BE@FMSMSX105.amr.corp.intel.com>
 <5373B2FD.5060505@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38429 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750777AbaENSWt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 14:22:49 -0400
In-Reply-To: <5373B2FD.5060505@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Sergei Shtylyov
>[mailto:sergei.shtylyov@cogentembedded.com]
>Sent: Wednesday, May 14, 2014 11:16 AM
>To: Tantilov, Emil S; Kirsher, Jeffrey T;
>davem@davemloft.net
>Cc: netdev@vger.kernel.org; gospo@redhat.com;
>sassmann@redhat.com
>Subject: Re: [net-next 01/11] ixgbe: fix detection of SFP+
>capable interfaces
>
>Hello.
>
>On 05/14/2014 08:59 PM, Tantilov, Emil S wrote:
>
>>>> From: Emil Tantilov <emil.s.tantilov@intel.com>
>
>>>> In cases where the driver is loaded while there are no
>SFP+ modules in
>>>> the cage the interface was not being detected as SFP
>capable. To account
>>>> for this the driver called identify_sfp in
>ixgbe_get_settings to make
>>>> sure the data is correct. However when there is no SFP+
>module in the cage
>>>> the driver waits for the I2C reads to time out which can
>take more than a
>>>> second and will cause issues with tools (like net-snmp)
>that may poll
>>>> for that information.
>
>>>> This patch resolves the issue by identifying 82599 based
>NIC with no PHY
>>>> type set as SFP capable which allows the driver to
>detect the SFP module
>>>> when the interface is brought up. As result of this we
>can also remove the
>>>> identify_sfp call from ixgbe_get_settings.
>
>>>> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
>>>> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
>>>> Signed-off-by: Jeff Kirsher
><jeffrey.t.kirsher@intel.com>
>
>>> [...]
>
>>>> diff --git
>a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>>> b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>>> index 8089ea9..e44c42a 100644
>>>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>>> @@ -4660,6 +4660,10 @@ static inline bool
>ixgbe_is_sfp(struct ixgbe_hw *hw)
>>>>    	case ixgbe_phy_nl:
>>>>    		if (hw->mac.type == ixgbe_mac_82598EB)
>>>>    			return true;
>>>> +	/* ixgbe_phy_none is set when no SFP module is
>present */
>>>> +	case ixgbe_phy_none:
>>>> +		if (hw->mac.type == ixgbe_mac_82599EB)
>>>> +			return true;
>
>>>     Shouldn't it just be combined with the previous case?
>
>> How can you combine them? The previous case is for
>ixgbe_phy_nl and 82598 macs this patch is for ixgbe_phy_none
>and 82599.
>
>    Ah, sorry, I've misread 82598EB as 82599EB.

Actually there is a problem with this patch due to this and the previous case falling through which can theoretically lead to a wrong return value. 

Please do not apply this patch. I will submit ver 2.

Thanks for reviewing!
Emil
