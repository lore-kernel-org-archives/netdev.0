From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 00/16] mlxsw: Multicast flood update
Date: Wed, 20 Sep 2017 18:05:12 -0700 (PDT)
Message-ID: <20170920.180512.587163028605109912.davem@davemloft.net>
References: <20170920141516.1402-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nogahf@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45366 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751769AbdIUBFN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 21:05:13 -0400
In-Reply-To: <20170920141516.1402-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 20 Sep 2017 16:15:00 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Nogah says:
> 
> Currently, there are four erroneous flows in MC flood:
> 1. When MC is disabled it affects only the flood table for unregistered
>    MC packets, but packets that match an entry in the MDB are unaffected.
> 2. When MC is disabled, MC packets are being sent to all the ports in the
>    bridge (like BC and link-local MC packets) regardless of the designated
>    flag (BR_MCAST_FLAG).
> 3. When a port is being deleted from a bridge it might remain in the MDB.
> 4. When MC is enabled packets are flooded to the mrouter ports only if
>    they don't match any entry in the MDB, when they should always be
>    flooded to them.
> 
> What these problems have in common is the discrepancy between how the
> hardware handles MDB and mcast flood, and how the driver does it. Each
> of these problems needs fixing either in the MDB code, or in mcast flood
> code, and some in both.
> 
> Patches 1-6 change the way the MDB is handled in the driver to make the
> following changes easier.
> Patches 7-8 fix problem number 1 by removing the MDB from the HW when MC
> is being disabled and restoring it when it is being enabled.
> Patches 9-10 fix problem number 2 by offloading the flood table by the
> appropriate flag.
> Patch 11 fixes problem number 3 by adding MDB flush to the port removal.
> Patches 12-14 fix problem number 4 by adding the mrouter ports to every
> MDB entry in the HW to mimic the wanted behaviour.

Looks good, series applied, thanks!
