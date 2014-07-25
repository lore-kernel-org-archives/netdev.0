From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2 0/3] net: forbid net devices named "all" "default" or "config"
Date: Fri, 25 Jul 2014 15:25:07 -0700
Message-ID: <1406327110-17227-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: stephane.chazelas@gmail.com, f.fainelli@gmail.com,
	davem@davemloft.net, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:42025 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490AbaGYWZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 18:25:29 -0400
Received: by mail-pd0-f180.google.com with SMTP id y13so6400350pdi.39
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2014 15:25:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

/proc/sys/net/ipv[46]/conf/<dev> could conflict with
/proc/sys/net/ipv[46]/conf/(all|default). And /proc/net/vlan/<dev>
could conflict with /proc/net/vlan/config. Besides kernel warnings,
undefined behavior such as duplicated proc files also appears, therefore
we should forbid these names.

v2: introduce a helper function, suggested by Florian 
    fix error handling for ipv6_add_dev() in addrconf_init()


Cong Wang (3):
  ipv4: fail early when creating netdev named all or default
  ipv6: fail early when creating netdev named all or default
  vlan: fail early when creating netdev named config

 include/net/ip.h     |  6 ++++
 net/8021q/vlan.c     | 21 +++++++++-----
 net/8021q/vlanproc.c |  2 ++
 net/ipv4/devinet.c   | 36 +++++++++++++++++------
 net/ipv6/addrconf.c  | 82 ++++++++++++++++++++++++++++++++++------------------
 5 files changed, 102 insertions(+), 45 deletions(-)

-- 
1.8.3.1
