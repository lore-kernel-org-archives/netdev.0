From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH] ixgbe: Correctly disable vlan filter in promiscuous mode
Date: Wed, 19 Nov 2014 21:50:56 +0000
Message-ID: <87618083B2453E4A8714035B62D67992501A1011@FMSMSX105.amr.corp.intel.com>
References: <1416338897-13007-1-git-send-email-vyasevic@redhat.com>
 <87618083B2453E4A8714035B62D679925019F38A@FMSMSX105.amr.corp.intel.com>
 <546CF258.9050205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
To: Vlad Yasevich <vyasevich@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:39072 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932693AbaKSVu6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 16:50:58 -0500
In-Reply-To: <546CF258.9050205@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Vlad Yasevich [mailto:vyasevich@gmail.com]
>Sent: Wednesday, November 19, 2014 11:41 AM
>To: Tantilov, Emil S; netdev@vger.kernel.org
>Cc: Kirsher, Jeffrey T; Keller, Jacob E; Skidmore, Donald C
>Subject: Re: [PATCH] ixgbe: Correctly disable vlan filter in
>promiscuous mode
>
>On 11/18/2014 03:24 PM, Tantilov, Emil S wrote:
>>> -----Original Message-----
>>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>>> owner@vger.kernel.org] On Behalf Of Vladislav Yasevich
>>> Sent: Tuesday, November 18, 2014 11:28 AM
>>> To: netdev@vger.kernel.org
>>> Cc: Vladislav Yasevich; Kirsher, Jeffrey T; Keller, Jacob E
>>> Subject: [PATCH] ixgbe: Correctly disable vlan filter in promiscuous mode
>>>
>>> IXGBE adapater seems to require that vlan filtering be enabled if VMDQ
>>> or SRIOV are enabled.  When those functions are disabled,
>>> vlan filtering may be disabled in promiscuous mode.
>>>
>>> Prior to commit a9b8943ee129e11045862d6d6e25c5b63c95403c
>>>    ixgbe: remove vlan_filter_disable and enable functions
>>>
>>> the logic was correct.  However, after the commit the logic
>>> got reversed and vlan filtered in now turned on when VMDQ/SRIOV
>>> is disabled.
>>>
>>> This patch changes the condition to enable hw vlan filtered
>>> when VMDQ or SRIOV is enabled.
>>>
>>> Fixes: a9b8943ee129e11045862d6d6e25c5b63c95403c (ixgbe:
>>> remove
>>> vlan_filter_disable and enable functions)
>>> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>> CC: Jacob Keller <jacob.e.keller@intel.com>
>>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>>> ---
>>> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 ++--
>>> 1 file changed, 2 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>> b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>> index d2df4e3..3f81c7a 100644
>>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>> @@ -3936,8 +3936,8 @@ void ixgbe_set_rx_mode(struct
>>> net_device *netdev)
>>> 		 * if SR-IOV and VMDQ are disabled - otherwise ensure
>>> 		 * that hardware VLAN filters remain enabled.
>>> 		 */
>>> -		if (!(adapter->flags & (IXGBE_FLAG_VMDQ_ENABLED |
>>> -					IXGBE_FLAG_SRIOV_ENABLED)))
>>> +		if (adapter->flags & (IXGBE_FLAG_VMDQ_ENABLED |
>>> +				      IXGBE_FLAG_SRIOV_ENABLED))
>>> 			vlnctrl |= (IXGBE_VLNCTRL_VFE |
>>> IXGBE_VLNCTRL_CFIEN);
>>> 	} else {
>>> 		if (netdev->flags & IFF_ALLMULTI) {
>>
>> The current logic is correct and it's like this on purpose
>> as it should be obvious by the comment preceding this check.
>
>Actually the comment right now does not match what the code
>is doing.
>
>The comment states:
>                /* Only disable hardware filter vlans in promiscuous mode
>                 * if SR-IOV and VMDQ are disabled - otherwise ensure
>                 * that hardware VLAN filters remain enabled.
>                 */
>
>However, the code currently will _enable_ vlan filtering if VMDQ/SRIOV
>is _disabled_ in promiscuous mode.

Actually you're right. Sorry - I misread the patch initially.
This is indeed a bug in the code.

Acked-by: Emil Tantilov <emil.s.tantilov@intel.com>

Jeff should pick it up.

Thanks,
Emil
