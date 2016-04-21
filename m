From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/3] bridge: mdb: Couple of fixes
Date: Thu, 21 Apr 2016 12:52:42 +0200
Message-ID: <1461235965-3930-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:35468 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543AbcDUKws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 06:52:48 -0400
Received: by mail-wm0-f43.google.com with SMTP id e201so82108992wme.0
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 03:52:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Elad says:

This patchset fixes two problems reported by Nikolay Aleksandrov. The first
problem is that the MDB offload flag might be accesed without helding the
multicast_lock.
The second problem is that the switchdev mdb offload is deferred and
the offload bit was marked regardless if the operation succeeded or not.

Elad Raz (3):
  switchdev: Adding complete operation to deferred switchdev ops
  bridge: mdb: Common function for mdb entry translation
  bridge: mdb: Marking port-group as offloaded

 include/net/switchdev.h   |   4 ++
 net/bridge/br_mdb.c       | 124 +++++++++++++++++++++++++++++-----------------
 net/bridge/br_multicast.c |   8 +--
 net/bridge/br_private.h   |   4 +-
 net/switchdev/switchdev.c |   6 +++
 5 files changed, 96 insertions(+), 50 deletions(-)

-- 
2.5.5
