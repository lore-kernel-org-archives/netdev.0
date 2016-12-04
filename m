From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v4 00/10] ipv4: fib: Replay events when
 registering FIB notifier
Date: Sat, 03 Dec 2016 19:30:02 -0500 (EST)
Message-ID: <20161203.193002.1316709458884546814.davem@davemloft.net>
References: <1480779907-32535-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        hannes@stressinduktion.org, kaber@trash.net
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39634 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751591AbcLDAaF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 19:30:05 -0500
In-Reply-To: <1480779907-32535-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sat,  3 Dec 2016 16:44:57 +0100

> Ido says:
> 
> In kernel 4.9 the switchdev-specific FIB offload mechanism was replaced
> by a new FIB notification chain to which modules could register in order
> to be notified about the addition and deletion of FIB entries. The
> motivation for this change was that switchdev drivers need to be able to
> reflect the entire FIB table and not only FIBs configured on top of the
> port netdevs themselves. This is useful in case of in-band management.
> 
> The fundamental problem with this approach is that upon registration
> listeners lose all the information previously sent in the chain and
> thus have an incomplete view of the FIB tables, which can result in
> packet loss. This patchset fixes that by dumping the FIB tables and
> replaying notifications previously sent in the chain for the registered
> notification block.
> 
> The entire dump process is done under RCU and thus the FIB notification
> chain is converted to be atomic. The listeners are modified accordingly.
> This is done in the first eight patches.
> 
> The ninth patch adds a change sequence counter to ensure the integrity
> of the FIB dump. The last patch adds the dump itself to the FIB chain
> registration function and modifies existing listeners to pass a callback
> to be executed in case dump was inconsistent.
 ...

Series applied, thanks.
