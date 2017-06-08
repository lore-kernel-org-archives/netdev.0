From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] netlink: don't send unknown nsid
Date: Thu, 8 Jun 2017 10:31:53 +0200
Message-ID: <057303a1-5d27-1b24-c8b0-d3cf46b14825@6wind.com>
References: <4942f9fe-625b-bb97-7b45-4a1e8bf69b1b@6wind.com>
 <1496304007-1962-1-git-send-email-nicolas.dichtel@6wind.com>
 <20170601170246.GF2673@x240.lan>
 <75fccaea-0ebe-1a2a-27d7-ad30fd99f41d@6wind.com>
 <20170601224454.GG2673@x240.lan>
 <58321cd0-6c7f-d4d8-628f-2c124d71ef82@6wind.com>
 <20170607183746.GD2658@x240.lan>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Flavio Leitner <fbl@sysclose.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36057 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751049AbdFHIb5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 04:31:57 -0400
Received: by mail-wm0-f49.google.com with SMTP id 7so132890923wmo.1
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 01:31:56 -0700 (PDT)
In-Reply-To: <20170607183746.GD2658@x240.lan>
Content-Language: fr
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/06/2017 à 21:14, Flavio Leitner a écrit :
> On Mon, Jun 05, 2017 at 10:40:24AM +0200, Nicolas Dichtel wrote:
>>> Let me ask this instead: How do you think userspace should behave when
>>> netnsid allocation fails?
>>>
>> There is two ways to assign a nsid:
>>  - manually with netlink ('ip netns set'). In this case, the error is reported
>>    to userspace via netlink.
> 
> OK.
> 
>>  - automatically when a x-netns interface is created. The link-nsid is also
>>    reported to userspace. If the allocation failed, NETNSA_NSID_NOT_ASSIGNED is
>>    reported. And if you were able to create this x-netns interface, it means
>>    that you have access to this peer netns, thus you can try to assign the nsid
>>    manually.
> 
> Does that prevent the interface to be created?
No.

> 
>> So, in both cases, userland knows that something went wrong.
>> Do you have another scenario in mind?
> 
> Let's say the app is restarted, or another monitoring app is executed
> with enough perms.  How will it identify the error condition?
Your app wants to monitor a subset of netns. It means that you already have a
way to identify those netns, something like a file stored somewhere
(/var/run/netns/, /proc/<pid>/ns/net, ...). Thus, it's easy to check if those
netns have a nsid assigned in the netns where your app will open the socket.

This option was called NETLINK_F_LISTEN_ALL_NSID, because it only enables to
listen netns *with* a nsid assigned, nothing more. It's up to the user to ensure
that nsid are correctly assigned.


Regards,
Nicolas
