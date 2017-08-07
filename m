From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v3 00/13] Update DSA's FDB API and perform switchdev cleanup
Date: Mon, 07 Aug 2017 10:59:57 -0400
Message-ID: <87bmnrifte.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch, Woojung.Huh@microchip.com,
        mlxsw@mellanox.com, Arkadi Sharshevsky <arkadis@mellanox.com>
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:33154 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751523AbdHGPDA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 11:03:00 -0400
In-Reply-To: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arkadi,

Arkadi Sharshevsky <arkadis@mellanox.com> writes:

> The patchset adds support for configuring static FDB entries via the
> switchdev notification chain. The current method for FDB configuration
> uses the switchdev's bridge bypass implementation. In order to support 
> this legacy way and to perform the switchdev cleanup, the implementation
> is moved inside DSA.
>
> The DSA drivers cannot sync the software bridge with hardware learned
> entries and use the switchdev's implementation of bypass FDB dumping.
> Because they are the only ones using this functionality, the fdb_dump
> implementation is moved from switchdev code into DSA.
>
> Finally after this changes a major cleanup in switchdev can be done.
> ---
> Please see individual patches for patch specific change logs.
> v1->v2
> - Split MDB/vlan dump removal into core/driver removal.
>
> v2->v3
> - The self implementation for FDB add/del is moved inside DSA.

v3 behaves correctly:

    # bridge fdb add e4:1d:2d:a5:f0:2a dev lan3
    # bridge fdb add e4:1d:2d:a5:f0:4a dev lan4 master
    # bridge fdb show
    01:00:5e:00:00:01 dev eth0 self permanent
    01:00:5e:00:00:01 dev eth1 self permanent
    b6:f2:c8:3a:1c:71 dev lan0 master br0 permanent
    e4:1d:2d:a5:f0:2a dev lan3 self static
    e4:1d:2d:a5:f0:4a dev lan4 offload master br0 permanent
    e4:1d:2d:a5:f0:4a dev lan4 self static
    01:00:5e:00:00:01 dev br0 self permanent
    # bridge fdb del e4:1d:2d:a5:f0:2a dev lan3
    # bridge fdb del e4:1d:2d:a5:f0:4a dev lan4 master
    # bridge fdb show
    01:00:5e:00:00:01 dev eth0 self permanent
    01:00:5e:00:00:01 dev eth1 self permanent
    b6:f2:c8:3a:1c:71 dev lan0 master br0 permanent
    01:00:5e:00:00:01 dev br0 self permanent

Tested-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>


Thanks,

        Vivien
