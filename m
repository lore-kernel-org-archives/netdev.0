From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: using rcu_read_lock() after calling dst_neigh_lookup
Date: Tue, 10 Jan 2017 16:22:51 +0200
Message-ID: <ead29087-05cc-c586-3b7e-d37c2e6f753c@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <ogerlitz@mellanox.com>,
        <idosch@mellanox.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0075.outbound.protection.outlook.com ([104.47.1.75]:17802
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752423AbdAJOXE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Jan 2017 09:23:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Drivers which are calling dst_neigh_lookup() are also using 
rcu_read_lock() before accessing the neigh pointer (and asking it's ll 
address data and its validity state).

You can find the same behavior in:

drivers/infiniband/core/addr.c, drivers/infiniband/hw/i40iw/i40iw_cm.c, 
drivers/infiniband/hw/nes/nes_cm.c, etc.

(the above locations are just an example).

While the documentation in neighbour.c says:

  "Neighbour entries are protected:
    - with reference count.
    - with rwlock neigh->lock
    Reference count prevents destruction.
    neigh->lock mainly serializes ll address data and its validity state."

So what is the right way to protect the neigh entry parameters? I 
couldn't find why rcu_read_lock() is helping here (dst_neigh_lookup 
already takes a reference on the neigh).

Thank you,

Hadar
