From: Thierry Herbelot <thierry.herbelot@6wind.com>
Subject: Re: [PATCH v3 net] ixgbe: check adapter->vfinfo before dereference
Date: Thu, 16 Oct 2014 09:34:13 +0200
Message-ID: <543F74F5.1040706@6wind.com>
References: <1412930732-892-1-git-send-email-thierry.herbelot@6wind.com>	 <1413367080-31540-1-git-send-email-thierry.herbelot@6wind.com>	 <87618083B2453E4A8714035B62D67992500E2629@FMSMSX105.amr.corp.intel.com>	 <543F7255.7070606@6wind.com> <1413444750.2412.43.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:48728 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178AbaJPHeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2014 03:34:17 -0400
Received: by mail-wg0-f43.google.com with SMTP id m15so3000735wgh.26
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2014 00:34:15 -0700 (PDT)
In-Reply-To: <1413444750.2412.43.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/2014 09:32 AM, Jeff Kirsher wrote:
> On Thu, 2014-10-16 at 09:23 +0200, Thierry Herbelot wrote:
>> On 10/16/2014 12:50 AM, Tantilov, Emil S wrote:
>>>> -----Original Message-----
>>>> From: Thierry Herbelot [mailto:thierry.herbelot@6wind.com]
>>>> Sent: Wednesday, October 15, 2014 2:58 AM
>>>> To: Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W;
>>>> netdev@vger.kernel.org; Tantilov, Emil S
>>>> Cc: Thierry Herbelot
>>>> Subject: [PATCH v3 net] ixgbe: check adapter->vfinfo before dereference
>>>>
>>>> this protects against the following panic:
>>>> (before a VF was actually created on p96p1 PF Ethernet port)
>>>>
>>>> ip link set p96p1 vf 0 spoofchk off
>>>> BUG: unable to handle kernel NULL pointer dereference at 0000000000000052
>>>> IP: [<ffffffffa044a1c1>]
>>>> ixgbe_ndo_set_vf_spoofchk+0x51/0x150 [ixgbe]
>>>>
>>>> Signed-off-by: Thierry Herbelot <thierry.herbelot@6wind.com>
>>>> ---
>>>>
>>>> v2:
>>>>    compilation fixes
>>>>
>>>> v3:
>>>>    remove checks in functions where vfinfo is known not to be NULL
>>>>    return -EINVAL as error code
>>>>
>>>> drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |   42
>>>> ++++++++++++++++++++++--
>>>> 1 file changed, 40 insertions(+), 2 deletions(-)
>>>
>>> Actually looking into this a bit more, the check for vfinfo is not sufficient
>>> because it does not protect against specifying vf that is outside of sriov_num_vfs range.
>>>
>>> All of the ndo functions have a check for it except for ixgbevf_ndo_set_spoofcheck().
>>>
>>> The following patch should be all we need to protect against this panic:
>>>
>>> This patch adds a check to return -EINVAL when setting spoofcheck on
>>> VF that is not configured.
>>>
>>> Reported-by: Thierry Herbelot <thierry.herbelot@6wind.com>
>>> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
>>> ---
>>>    drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |    3 +++
>>>    1 file changed, 3 insertions(+)
>>>
>>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
>>> index 706fc69..97c85b8 100644
>>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
>>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
>>> @@ -1261,6 +1261,9 @@ int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting)
>>>    	struct ixgbe_hw *hw = &adapter->hw;
>>>    	u32 regval;
>>>
>>> +	if (vf >= adapter->num_vfs)
>>> +		return -EINVAL;
>>> +
>>>    	adapter->vfinfo[vf].spoofchk_enabled = setting;
>>>
>>>    	regval = IXGBE_READ_REG(hw, IXGBE_PFVFSPOOF(vf_target_reg));
>>>
>>>
>>
>> Hello,
>>
>> Indeed your patch solves the initial issue.
>>
>> And indeed I also double-checked that all other instances are protected
>> by the (vf >= adapter->num_vfs) condition.
>
> So Thierry, can I add your Acked-by or Tested-by to Emil's patch?
>

Hello,

I agree with the patch.

Acked-by Thierry Herbelot <thierry.herbelot@6wind.com>

	Best regards

	Th

-- 
Thierry Herbelot
6WIND
Software Engineer
