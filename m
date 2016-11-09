From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: Why are IPv6 host and anycast routes referencing lo device?
Date: Wed, 9 Nov 2016 13:30:40 -0700
Message-ID: <c4f8beae-f912-dcd6-cbe1-d6d29618c4b1@cumulusnetworks.com>
References: <db922fb9-2553-7801-d597-0f40999be944@cumulusnetworks.com>
 <a2955697-9cd2-9f27-9d15-4f9ed95561ec@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34788 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751674AbcKIUam (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 15:30:42 -0500
Received: by mail-pf0-f177.google.com with SMTP id n85so132138070pfi.1
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 12:30:42 -0800 (PST)
In-Reply-To: <a2955697-9cd2-9f27-9d15-4f9ed95561ec@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/8/16 10:08 AM, Hannes Frederic Sowa wrote:
> On 08.11.2016 02:08, David Ahern wrote:
>>
>> Can anyone explain why host routes and anycast routes for IPv6 are added with the device set to loopback versus the device with the address:
>>
>> local ::1 dev lo  proto none  metric 0  pref medium
>> local 2000:1:: dev lo  proto none  metric 0  pref medium
>> local 2000:1::3 dev lo  proto none  metric 0  pref medium
>> local 2100:2:: dev lo  proto none  metric 0  pref medium
>> local 2100:2::3 dev lo  proto none  metric 0  pref medium
> 
> Does it really matter? For global valid unicast addresses we still
> implement the weak model. Thus the interface does not matter at all.

Consistency. Why does IPv6 need to have all of these little differences from IPv4? Raises questions from customers, customer support and often requires special handling in s/w. 

> 
>> This behavior differs from IPv4 where host routes use the device with the address:
>>
>> broadcast 10.1.1.0 dev eth0  proto kernel  scope link  src 10.1.1.3
>> local 10.1.1.3 dev eth0  proto kernel  scope host  src 10.1.1.3
>> broadcast 10.1.1.255 dev eth0  proto kernel  scope link  src 10.1.1.3
>> broadcast 10.100.2.0 dev eth2  proto kernel  scope link  src 10.100.2.3
>> local 10.100.2.3 dev eth2  proto kernel  scope host  src 10.100.2.3
>> broadcast 10.100.2.255 dev eth2  proto kernel  scope link  src 10.100.2.3
>>
>> The use of loopback pre-dates the git history, so wondering if someone recalls the reason why. We would like to change that to make it consistent with IPv4 - with a sysctl to maintain backwards compatibility.
> 
> A sysctl for that sounds like a really bad idea.
> 
> Internally the sysctl will change the reference counting of interfaces
> and routes towards each other, have small but difficult to find
> semantically changes inside the kernel, just for switchting the
> interface in iproute/netlink dumps?
> 
> If there a good reasons (which can very well be) to switch to have the
> interface with the address in the routes, we should switch without
> providing the backwards compatibility sysctl.

Works for me. I'd prefer not to add yet another sysctl but that seems to be standard for cases like this.
