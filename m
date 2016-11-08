From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: Why are IPv6 host and anycast routes referencing lo device?
Date: Tue, 8 Nov 2016 11:26:34 +0900
Message-ID: <14a4ccfb-11d9-f96b-a741-c8595b81ca45@miraclelinux.com>
References: <db922fb9-2553-7801-d597-0f40999be944@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com
To: David Ahern <dsa@cumulusnetworks.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34340 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752693AbcKHC0i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 21:26:38 -0500
Received: by mail-pf0-f173.google.com with SMTP id n85so99250832pfi.1
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2016 18:26:37 -0800 (PST)
In-Reply-To: <db922fb9-2553-7801-d597-0f40999be944@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

David Ahern wrote:
> 
> Can anyone explain why host routes and anycast routes for IPv6 are added with the device set to loopback versus the device with the address:
> 
> local ::1 dev lo  proto none  metric 0  pref medium
> local 2000:1:: dev lo  proto none  metric 0  pref medium
> local 2000:1::3 dev lo  proto none  metric 0  pref medium
> local 2100:2:: dev lo  proto none  metric 0  pref medium
> local 2100:2::3 dev lo  proto none  metric 0  pref medium
> 
> 
> This behavior differs from IPv4 where host routes use the device with the address:
> 
> broadcast 10.1.1.0 dev eth0  proto kernel  scope link  src 10.1.1.3
> local 10.1.1.3 dev eth0  proto kernel  scope host  src 10.1.1.3
> broadcast 10.1.1.255 dev eth0  proto kernel  scope link  src 10.1.1.3
> broadcast 10.100.2.0 dev eth2  proto kernel  scope link  src 10.100.2.3
> local 10.100.2.3 dev eth2  proto kernel  scope host  src 10.100.2.3
> broadcast 10.100.2.255 dev eth2  proto kernel  scope link  src 10.100.2.3
> 
> The use of loopback pre-dates the git history, so wondering if someone recalls the reason why. We would like to change that to make it consistent with IPv4 - with a sysctl to maintain backwards compatibility.

Once I tried I did not work.
You could try again to see what happens.

--yoshfuji

> 
> Thanks,
> David
> 

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
