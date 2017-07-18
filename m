From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 07/11] net: dsa: Remove support for bypass bridge port attributes/vlan set
Date: Tue, 18 Jul 2017 13:40:54 -0400
Message-ID: <87d18xbq3d.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1500387624-4361-1-git-send-email-arkadis@mellanox.com> <1500387624-4361-8-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com,
        Arkadi Sharshevsky <arkadis@mellanox.com>
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:51248 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751775AbdGRRni (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 13:43:38 -0400
In-Reply-To: <1500387624-4361-8-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arkadi,

Arkadi Sharshevsky <arkadis@mellanox.com> writes:

> The bridge port attributes/vlan for DSA devices should be set only
> from bridge code. Furthermore, The vlans are synced totally with the
> bridge so there is no need for special dump support.
>
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> ---
>  drivers/net/dsa/b53/b53_common.c       | 44 --------------------------
>  drivers/net/dsa/b53/b53_priv.h         |  3 --
>  drivers/net/dsa/bcm_sf2.c              |  1 -
>  drivers/net/dsa/dsa_loop.c             | 38 -----------------------
>  drivers/net/dsa/microchip/ksz_common.c | 41 -------------------------
>  drivers/net/dsa/mv88e6xxx/chip.c       | 56 ----------------------------------
>  include/net/dsa.h                      |  4 ---
>  net/dsa/dsa_priv.h                     |  4 ---
>  net/dsa/port.c                         | 12 --------
>  net/dsa/slave.c                        |  6 ----

Regarding this massive deletion, can you please split it in two patches,
one deleting first the DSA core usage of .port_vlan_dump, i.e. in:

    net/dsa/dsa_priv.h
    net/dsa/port.c
    net/dsa/slave.c

Then a second patch which deletes the .port_vlan_dump implementations?

This may sound useless but it will actually make it easy for us to
restore the VLAN dump support in drivers once we introduce an
alternative way to query the hardware.


Thanks,

        Vivien
