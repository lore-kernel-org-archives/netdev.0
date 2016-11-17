From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 6/8] ipv4: fib: Add an API to request a FIB
 dump
Date: Thu, 17 Nov 2016 11:45:29 -0500 (EST)
Message-ID: <20161117.114529.1851585222876647915.davem@davemloft.net>
References: <56d2179d-00ff-bcc5-e365-845179cbe672@stressinduktion.org>
        <20161117131049.pevkla5os75h4zlc@splinter.mtl.com>
        <e2e0eaaf-30f0-e825-29c7-920115742301@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: idosch@idosch.org, jiri@resnulli.us, netdev@vger.kernel.org,
        idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
        nogahf@mellanox.com, arkadis@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, andy@greyhouse.net,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39760 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932854AbcKQRB7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 12:01:59 -0500
In-Reply-To: <e2e0eaaf-30f0-e825-29c7-920115742301@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 17 Nov 2016 15:36:48 +0100

> The other way is the journal idea I had, which uses an rb-tree with
> timestamps as keys (can be lamport timestamps). You insert into the tree
> until the dump is finished and use it as queue later to shuffle stuff
> into the hardware.

If you have this "place" where pending inserts are stored, you have
a policy decision to make.

First of all what do other lookups see when there are pending entires?

If, once inserted into the pending queue, you return success to the
inserting entity, then you must make those pending entries visible
to lookups.

If you block the inserting entity, well that doesn't make a lot of
sense.  If blocking is a workable solution, then we can just block the
entire insert while this FIB dump to the device driver is happening.

But I am pretty sure the idea of blocking modifications for so long
was considered undesirable.
