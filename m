From: "Patil, Kiran" <kiran.patil@intel.com>
Subject: Re: [net-next 08/15] i40e: Allow user to change input set mask for
 flow director
Date: Thu, 5 May 2016 08:00:21 -0700
Message-ID: <572B6005.9060408@intel.com>
References: <1461704148-114349-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1461704148-114349-9-git-send-email-jeffrey.t.kirsher@intel.com>
 <20160426.234814.31916479145118247.davem@davemloft.net>
 <572AB43E.2020007@intel.com> <572ABC76.2080600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: John Fastabend <john.fastabend@gmail.com>,
	David Miller <davem@davemloft.net>, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31987 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753503AbcEEPAY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2016 11:00:24 -0400
In-Reply-To: <572ABC76.2080600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/4/2016 8:22 PM, John Fastabend wrote:
> On 16-05-04 07:47 PM, Patil, Kiran wrote:
>> On 4/26/2016 8:48 PM, David Miller wrote:
>>> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>> Date: Tue, 26 Apr 2016 13:55:41 -0700
>>>
>>>> From: Kiran Patil <kiran.patil@intel.com>
>>>>
>>>> This patch implements feature, which allows user to change
>>>> input set mask for flow director using side-band channel.
>>>> This patch adds definition of FLOW_TYPE_MASK into the header file.
>>>> With this patch, user can now specify less than 4 tuple(src ip, dsp ip,
>>>> src port, dst port) for flow type TCP4/UDP4.
>>>>
>>>> Change-Id: I90052508f8c172c0da5a4b78b949704b4a59ea78
>>>> Signed-off-by: Kiran Patil <kiran.patil@intel.com>
>>>> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
>>>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>>
>>> If you want to do this, you have to define the semantics generically
>>> in include/uapi/linux/ethtool.h so that other drivers can implement
>>> this too.
>>>
>>> Please don't ever implement private, driver specific, interpretations
>>> of the generic ethtool facilitites.
>>>
>>> The semantics and interpretations of the values must absolutely be
>>> consistent across all drivers in the tree.
>>>
>>> Otherwise the user experience is terrible.
>>>
>>> Thanks.
>>>
>> This is not new feature implemented in i40e driver. This is the original
>> feature of ethtool which allows user to specify subset of tuple for
>> setting up flow director.
>>
>> i40e driver using it same way as ixgbe.
>>
>> Please let us know if I misinterpreted your response.
>>
>> Would you recommend that we re-submit patch with better patch
>> description (indicating that it is not new feature but just enabling
>> feature).
>>
>> Thanks,
>> -- Kiran P.
>
> At least define FLOW_TYPE_MASK in ethtool.h then its not
> sort of hobbled together in the driver and others can use it
> instead of the normal ~FLOW_EXT which I see other drivers used.
> Another benefit if its near the definition of the flow types
> you have a chance of someone seeing it if they add a flag
> past 0xff.
>
> And maybe do it as a separate patch. So you aren't adding normal
> driver ethtool implementation and a new #define for all drivers
> in the same patch.
>
> .John
>
Now I see what the problem is (FLOW_TYPE_MASK). Unfortunately it was 
never meant to be part of this patch since it was introduced by other 
patch (Cloud filter support) and was suggested to move into this header 
file. As suggested, we can create another patch just for this 
FLOW_TYPE_MASK in ethtool.h and re-work original patch to not have 
define for FLOW_TYPE_MASK.

May be we can go back and think, it this define absolutely needed or not.

Thanks,
-- Kiran P.
