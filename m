From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 0/3] net: forbid net devices named "all" "default" or "config"
Date: Wed, 23 Jul 2014 15:17:29 -0700
Message-ID: <1406153852-22511-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: stephane.chazelas@gmail.com, davem@davemloft.net,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:64462 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933386AbaGWWRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 18:17:53 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so2389113pdj.40
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 15:17:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

/proc/sys/net/ipv[46]/conf/<dev> could conflict with
/proc/sys/net/ipv[46]/conf/(all|default). And /proc/net/vlan/<dev>
could conflict with /proc/net/vlan/config. Besides kernel warnings,
undefined behavior such as duplicated proc files also appears, therefore
we should forbid these names.

Cong Wang (3):
  ipv4: fail early when creating netdev named all or default
  ipv6: fail early when creating netdev named all or default
  vlan: fail early when creating netdev named config

 net/8021q/vlan.c     | 21 +++++++++-------
 net/8021q/vlanproc.c |  2 ++
 net/ipv4/devinet.c   | 37 ++++++++++++++++++++++-------
 net/ipv6/addrconf.c  | 67 ++++++++++++++++++++++++++++++++++------------------
 4 files changed, 87 insertions(+), 40 deletions(-)

-- 
1.8.3.1
