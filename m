From: Brad Campbell <lists2009@fnarfbargle.com>
Subject: commit a52ad514fdf3b8a57ca4322c92d2d8d5c6182485 net: deprecate
 eth_change_mtu, remove usage breaks bonding on my machine
Date: Thu, 2 Mar 2017 00:11:09 +0800
Message-ID: <0be1a70f-8593-ac8c-5f22-ee6676dfc672@fnarfbargle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: jarod@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns3.fnarfbargle.com ([43.245.164.105]:36081 "EHLO
        ns3.fnarfbargle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751038AbdCARIf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 12:08:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

G'day Jarod,

I have a pair of machines that are linked by a pair of quad port e1000 
cards with all 4 ports bonded. The network is configured with an mtu of 
9000.

Kernel 4.10 fails to bring these interfaces up as it fails when trying 
to set the mtu on the bond interface higher than 1500. A bisect between 
4.9 & 4.10 winds up identifying this commit as where it all goes wrong. 
If I modify the network config to not touch the mtu (ie leave it at 
1500) then it comes up ok.

I can individually configure each port with an mtu of 9000, so the e1000 
driver is ok, but there appears to be breakage in the bonding driver 
related to your mtu api changes.

I've just reverted to an older kernel, so it's no biggie. And as it's 
still a problem in the latest git head I assume nobody else has 
encountered it. I thought it worth reporting in case it triggers a quick 
lightbulb.

Regards,
Brad.
