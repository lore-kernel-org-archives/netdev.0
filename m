From: Michal Humpula <michal.humpula@hudrydum.cz>
Subject: nonlocal_bind & IPv6
Date: Fri, 25 Jun 2010 20:43:45 +0200
Message-ID: <201006252043.45581.michal.humpula@hudrydum.cz>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hudrydum.cz ([88.208.90.178]:55582 "EHLO hudrydum.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756723Ab0FYSwN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jun 2010 14:52:13 -0400
Received: from mekka.localnet (mekka.hudrydum.local [192.168.1.1])
	by hudrydum.cz (Postfix) with ESMTPSA id B6E36368F4
	for <netdev@vger.kernel.org>; Fri, 25 Jun 2010 20:43:46 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, 

I was just wondering, what's wrong with this?

*** linux-2.6.34/net/ipv6/af_inet6.c    2010-05-16 23:17:36.000000000 +0200
--- linux-2.6.34-hack/net/ipv6/af_inet6.c       2010-06-25 19:50:19.000000000 +0200
***************
*** 345,354 ****
--- 345,356 ----
                        if (!(addr_type & IPV6_ADDR_MULTICAST)) {
                                if (!ipv6_chk_addr(net, &addr->sin6_addr,
                                                   dev, 0)) {
+           if (!sysctl_ip_nonlocal_bind) {
                                        err = -EADDRNOTAVAIL;
                                        goto out_unlock;
            }
                                }
+                       }
                        rcu_read_unlock();
                }
        }

Motivation: just want to balance one IPv6 address between two nodes with the help of 
keepalived the same way I do it with IPv4 without the need of restarting the daemons 
binding on that IP.

Regards

Michal Humpula
