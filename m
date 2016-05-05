From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next 08/15] i40e: Allow user to change input set mask for
 flow director
Date: Wed, 4 May 2016 20:22:30 -0700
Message-ID: <572ABC76.2080600@gmail.com>
References: <1461704148-114349-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1461704148-114349-9-git-send-email-jeffrey.t.kirsher@intel.com>
 <20160426.234814.31916479145118247.davem@davemloft.net>
 <572AB43E.2020007@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: "Patil, Kiran" <kiran.patil@intel.com>,
	David Miller <davem@davemloft.net>, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35774 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756114AbcEEDWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 23:22:50 -0400
Received: by mail-pa0-f49.google.com with SMTP id iv1so30914072pac.2
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 20:22:49 -0700 (PDT)
In-Reply-To: <572AB43E.2020007@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-04 07:47 PM, Patil, Kiran wrote:
> On 4/26/2016 8:48 PM, David Miller wrote:
>> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Date: Tue, 26 Apr 2016 13:55:41 -0700
>>
>>> From: Kiran Patil <kiran.patil@intel.com>
>>>
>>> This patch implements feature, which allows user to change
>>> input set mask for flow director using side-band channel.
>>> This patch adds definition of FLOW_TYPE_MASK into the header file.
>>> With this patch, user can now specify less than 4 tuple(src ip, dsp ip,
>>> src port, dst port) for flow type TCP4/UDP4.
>>>
>>> Change-Id: I90052508f8c172c0da5a4b78b949704b4a59ea78
>>> Signed-off-by: Kiran Patil <kiran.patil@intel.com>
>>> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
>>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>
>> If you want to do this, you have to define the semantics generically
>> in include/uapi/linux/ethtool.h so that other drivers can implement
>> this too.
>>
>> Please don't ever implement private, driver specific, interpretations
>> of the generic ethtool facilitites.
>>
>> The semantics and interpretations of the values must absolutely be
>> consistent across all drivers in the tree.
>>
>> Otherwise the user experience is terrible.
>>
>> Thanks.
>>
> This is not new feature implemented in i40e driver. This is the original
> feature of ethtool which allows user to specify subset of tuple for
> setting up flow director.
> 
> i40e driver using it same way as ixgbe.
> 
> Please let us know if I misinterpreted your response.
> 
> Would you recommend that we re-submit patch with better patch
> description (indicating that it is not new feature but just enabling
> feature).
> 
> Thanks,
> -- Kiran P.

At least define FLOW_TYPE_MASK in ethtool.h then its not
sort of hobbled together in the driver and others can use it
instead of the normal ~FLOW_EXT which I see other drivers used.
Another benefit if its near the definition of the flow types
you have a chance of someone seeing it if they add a flag
past 0xff.

And maybe do it as a separate patch. So you aren't adding normal
driver ethtool implementation and a new #define for all drivers
in the same patch.

.John
