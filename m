From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net] ipv4: Avoid caching dsts when lookup skipped nh oif
 check
Date: Thu, 20 Apr 2017 15:39:43 +0100
Message-ID: <ec8e470e-73d0-b357-4f65-a4f7e020db7f@brocade.com>
References: <1492693132-4708-1-git-send-email-rshearma@brocade.com>
 <bed3d38c-dc00-1f98-371c-852170af0a0e@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:42817 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S941847AbdDTOj5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 10:39:57 -0400
In-Reply-To: <bed3d38c-dc00-1f98-371c-852170af0a0e@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/04/17 15:21, David Ahern wrote:
> On 4/20/17 6:58 AM, Robert Shearman wrote:
>> David reported that doing the following:
>>
>>     ip li add red type vrf table 10
>>     ip link set dev eth1 vrf red
>>     ip addr add 127.0.0.1/8 dev red
>>     ip link set dev eth1 up
>>     ip li set red up
>>     ping -c1 -w1 -I red 127.0.0.1
>>     ip li del red
>>
>> results in a hang with this message:
>>
>>     unregister_netdevice: waiting for red to become free. Usage count = 1
>
> I think you misunderstood my comment. The above works fine today. There
> is no bug with refcnts.
>
> It breaks with your patches wanting to use a VRF device with the main
> table (254).

That doesn't seem to match with my experience. I can reproduce this on 
the net tree with the listed commands and the behaviour matches what I 
see in the code.

Thanks,
Rob
