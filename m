From: Francesco Ruggeri <fruggeri@arista.com>
Subject: Cannot move macvlan interface on top of bonding device
Date: Wed, 17 Sep 2014 08:56:41 -0700
Message-ID: <CA+HUmGi74nx0zELqXX63nJCNXshTC9AkWoRG5bo6AMHyr_3+fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Weilong Chen <chenweilong@huawei.com>,
	Florian Westphal <fw@strlen.de>,
	Francesco Ruggeri <fruggeri@arista.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f48.google.com ([209.85.219.48]:46880 "EHLO
	mail-oa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755842AbaIQP4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 11:56:42 -0400
Received: by mail-oa0-f48.google.com with SMTP id g18so1315672oah.35
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 08:56:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I cannot move a macvlan interface created on top of a bonding interface
to a different namespace:

# ip netns add dummy0
# ip link add link bond0 mac0 type macvlan
# ip link set mac0 netns dummy0
RTNETLINK answers: Invalid argument
#

This used to work in older releases.
The problem seems to be that commit f939981492 sets NETIF_F_NETNS_LOCAL
on bonding interfaces, and commit 797f87f83 causes macvlan interfaces
to inherit its features from the lower device.

Is there a reason why NETIF_F_NETNS_LOCAL should be inherited from the
lower device
by macvlan interfaces?

Thanks,
Francesco Ruggeri
