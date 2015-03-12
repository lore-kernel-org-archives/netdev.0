From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next 0/4] bonding work-queues, try_rtnl() & notifications
Date: Wed, 11 Mar 2015 22:54:33 -0700
Message-ID: <1426139673-26995-1-git-send-email-maheshb@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:33534 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbbCLFyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 01:54:37 -0400
Received: by yhoa41 with SMTP id a41so2278411yho.0
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 22:54:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series tries to address the issue discovered in various work-
queues and the way these handlers deal with the RTNL. Especially for 
notification handling. If RTNL can not be acquired, these handlers ignore
sending notifications and just re-arm the timer. This could be very 
problematic if the re-arm timer has larger value (e.g. in minutes).


Mahesh Bandewar (4):
  bonding: Handle notifications during work-queue processing gracefully
  bonding: Do not ignore notifications for miimon-work-queue
  bonding: Do not ignore notifications for AD-work-queue
  bonding: Do not ignore notifications for ARP-work-queue

 drivers/net/bonding/bond_3ad.c  | 22 ++++++++++++---
 drivers/net/bonding/bond_main.c | 62 ++++++++++++++++++++++++-----------------
 include/net/bonding.h           | 22 +++++++++++++++
 3 files changed, 77 insertions(+), 29 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
