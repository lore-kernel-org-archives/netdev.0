From: David Ahern <dsa@cumulusnetworks.com>
Subject: Why are IPv6 host and anycast routes referencing lo device?
Date: Mon, 7 Nov 2016 18:08:25 -0700
Message-ID: <db922fb9-2553-7801-d597-0f40999be944@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36844 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751227AbcKHBJN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 20:09:13 -0500
Received: by mail-pf0-f169.google.com with SMTP id 189so98481161pfz.3
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2016 17:08:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Can anyone explain why host routes and anycast routes for IPv6 are added with the device set to loopback versus the device with the address:

local ::1 dev lo  proto none  metric 0  pref medium
local 2000:1:: dev lo  proto none  metric 0  pref medium
local 2000:1::3 dev lo  proto none  metric 0  pref medium
local 2100:2:: dev lo  proto none  metric 0  pref medium
local 2100:2::3 dev lo  proto none  metric 0  pref medium


This behavior differs from IPv4 where host routes use the device with the address:

broadcast 10.1.1.0 dev eth0  proto kernel  scope link  src 10.1.1.3
local 10.1.1.3 dev eth0  proto kernel  scope host  src 10.1.1.3
broadcast 10.1.1.255 dev eth0  proto kernel  scope link  src 10.1.1.3
broadcast 10.100.2.0 dev eth2  proto kernel  scope link  src 10.100.2.3
local 10.100.2.3 dev eth2  proto kernel  scope host  src 10.100.2.3
broadcast 10.100.2.255 dev eth2  proto kernel  scope link  src 10.100.2.3

The use of loopback pre-dates the git history, so wondering if someone recalls the reason why. We would like to change that to make it consistent with IPv4 - with a sysctl to maintain backwards compatibility.

Thanks,
David
