From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: VRF: Fix receiving multicast traffic
Date: Thu, 22 Sep 2016 16:41:00 -0600
Message-ID: <319068be-b1b9-c245-55d6-5e012e57487b@cumulusnetworks.com>
References: <20160922041308.30848-1-mark.tomlinson@alliedtelesis.co.nz>
 <aac5b560-d757-3281-8e69-7953e7c4b418@cumulusnetworks.com>
 <ee8de997-007c-4035-5f65-a8b389a138ac@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Mark Tomlinson <Mark.Tomlinson@alliedtelesis.co.nz>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33175 "EHLO
        mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758193AbcIVWlD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 18:41:03 -0400
Received: by mail-pa0-f45.google.com with SMTP id hm5so33433755pac.0
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 15:41:03 -0700 (PDT)
In-Reply-To: <ee8de997-007c-4035-5f65-a8b389a138ac@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/22/16 4:10 PM, Mark Tomlinson wrote:
> 
> On 09/23/2016 03:14 AM, David Ahern wrote:
>>
>> l3mdev devices do not support IPv4 multicast so checking mcast against that device should not be working at all. For that reason I was fine with the change in the previous patch. ie., you want the real ingress device there not the vrf device.
>>
>> What test are you running that says your previous patch broke something?
> Although we do not expect any multicast routing to work in an l3mdev, 
> (IGMP snooping or PIM), we still want to have multicast packets 
> delivered for protocols such as RIP. This was working before my previous 
> patch, but these multicast packets are now dropped. This current patch 
> fixes that again, hopefully still with the benefits of my first patch.
> 

can you discern which check is making that happen?

It does not make sense to look at the in_device of a vrf device for mcast addresses. For IPv6 linklocal and mcast is specifically blocked. IPv4 should do the same. So, how is RIP getting the packet at all?
