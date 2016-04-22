From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net v2 0/9] macsec: a few fixes
Date: Fri, 22 Apr 2016 11:28:00 +0200
Message-ID: <cover.1461315621.git.sd@queasysnail.net>
Cc: Lance Richardson <lrichard@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32959 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751868AbcDVJ2a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 05:28:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some small fixes for the macsec driver:
 - possible NULL pointer dereferences
 - netlink dumps fixes: RTNL locking, consistent dumps
 - a reference counting bug
 - wrong name for uapi constant
 - a few memory leaks

Patches 1 to 5 are the same as in v1, patches 6 to 9 are new.
Patch 6 fixes the memleak that Lance spotted in v1.

Sabrina Dubroca (9):
  macsec: add missing NULL check after kmalloc
  macsec: take rtnl lock before for_each_netdev
  macsec: don't put a NULL rxsa
  macsec: fix rx_sa refcounting with decrypt callback
  macsec: add consistency check to netlink dumps
  macsec: fix memory leaks around rx_handler (un)registration
  macsec: fix SA leak if initialization fails
  macsec: add missing macsec prefix in uapi
  macsec: fix netlink attribute validation

 drivers/net/macsec.c           | 65 +++++++++++++++++++++++++++---------------
 include/uapi/linux/if_macsec.h |  4 +--
 2 files changed, 44 insertions(+), 25 deletions(-)

-- 
2.8.0
