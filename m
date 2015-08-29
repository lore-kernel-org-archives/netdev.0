From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next 0/3] L3 RX handler
Date: Sat, 29 Aug 2015 08:05:45 -0700
Message-ID: <55E1CA49.9040803@cumulusnetworks.com>
References: <1440808463-14526-1-git-send-email-dsa@cumulusnetworks.com>
 <20150828.221404.100480720904987645.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33787 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753385AbbH2PFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 11:05:46 -0400
Received: by pacgr6 with SMTP id gr6so5777789pac.0
        for <netdev@vger.kernel.org>; Sat, 29 Aug 2015 08:05:45 -0700 (PDT)
In-Reply-To: <20150828.221404.100480720904987645.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/28/15 10:14 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Fri, 28 Aug 2015 17:34:20 -0700
>
>> Currently the VRF driver registers an Rx handler for enslaved devices.
>> The handler switches the skb->dev to the VRF device and sends it back for
>> another pass. While this works fine a side effect is that it bypasses
>> netfilter with the skb set to the original device.
>>
>> Looking at how to provide that feature a few options come to mind:
>> 1. Have the rx handler in the VRF driver duplicate some of the processing
>>     of ip_rcv up to the NF_HOOK and then switch the skb->dev to vrf device.
>>
>> 2. Run NF_HOOK in ip_rcv twice -- once with orig_dev and then again for dev.
>>
>> 3. Introduce an L3 rx-handler that provides the option of hooking packets
>>     at L3 rather than the current backlog loop.
>>
>> This RFC looks at option 3. I wanted to get opinions on the approach
>> versus other options.
>
> No way, this is not going to pass.

I'll drop this option. Thanks for the quick response.
