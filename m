From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv4: fib: Replay events when registering
 FIB notifier
Date: Wed, 02 Nov 2016 11:26:18 -0400 (EDT)
Message-ID: <20161102.112618.743617399868353432.davem@davemloft.net>
References: <5818B146.20209@cumulusnetworks.com>
        <20161101.113650.140429913221385583.davem@davemloft.net>
        <20161102073502.GB1713@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, eric.dumazet@gmail.com,
        idosch@idosch.org, netdev@vger.kernel.org, jiri@mellanox.com,
        mlxsw@mellanox.com, dsa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, andy@greyhouse.net,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, idosch@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40534 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753068AbcKBP0V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 11:26:21 -0400
In-Reply-To: <20161102073502.GB1713@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 2 Nov 2016 08:35:02 +0100

> How do you imagine this mode should looks like? Could you draw me some
> example?

Well, first of all, there is no reason we can't provide a mechanism by
which the driver can request and obtain a FIB dump.

And it can be designed in a way to be preemptible or at least not
require RTNL to be held during the entire operation.  Sequence
counters or similar can be used to make sure that if the table changes
mid-dump due to RTNL being dropped, the dump can be rewound and
restarted.
