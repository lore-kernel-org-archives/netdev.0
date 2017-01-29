From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 0/4] net: dsa: Port mirroring support
Date: Sun, 29 Jan 2017 11:46:37 -0800
Message-ID: <c6533daa-c036-6aef-1850-773996533ccc@gmail.com>
References: <20170129192910.6069-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        cphealy@gmail.com, jiri@mellanox.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f195.google.com ([74.125.82.195]:36218 "EHLO
        mail-ot0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751493AbdA2Tqp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 14:46:45 -0500
Received: by mail-ot0-f195.google.com with SMTP id 36so36325209otx.3
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 11:46:39 -0800 (PST)
In-Reply-To: <20170129192910.6069-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/29/2017 11:29 AM, Florian Fainelli wrote:
> Hi all,
> 
> This patch series adds support for port mirroring in the two
> Broadcom switch drivers. The major part of the functional are actually with
> the plumbing between tc and the drivers.
> 
> David, this will most likely conflict a little bit with my other series:
>  net: dsa: bcm_sf2: CFP support, so just let me know if that happens, and
> I will provide a rebased version. Thanks!

David, not sure why but patch 1 does not want to show up on patchwork,
and cross checking with spinics.net it's not on netdev@vger.kernel.org
either... you should have it in your inbox hopefully. git send-email did
return it was sent correctly. Let me know if you need me to resend the
whole series. Thanks!

> 
> Changes in v3:
> 
> - removed multiline comments from added structures
> - simplify error handling in dsa_slave_add_cls_matchall
> 
> Changes in v2:
> 
> - fixed filter removal logic to disable the ingress or egress mirroring
>   when there are no longer ports being monitored in ingress or egress
> 
> - removed a stray list_head in dsa_port structure that is not used
> 
> Tested using the two iproute2 examples:
> 
> # ingress
>       tc qdisc  add dev eth1 handle ffff: ingress
>       tc filter add dev eth1 parent ffff:           \
>                matchall skip_sw                      \
>                action mirred egress mirror           \
>                dev eth2
> # egress
>       tc qdisc add dev eth1 handle 1: root prio
>       tc filter add dev eth1 parent 1:               \
>                matchall skip_sw                       \
>                action mirred egress mirror            \
>                dev eth2
> 
> 
> Florian Fainelli (4):
>   net: dsa: Add plumbing for port mirroring
>   net: dsa: b53: Add mirror capture register definitions
>   net: dsa: b53: Add support for port mirroring
>   net: dsa: bcm_sf2: Add support for port mirroring
> 
>  drivers/net/dsa/b53/b53_common.c |  67 +++++++++++++++++++
>  drivers/net/dsa/b53/b53_priv.h   |   4 ++
>  drivers/net/dsa/b53/b53_regs.h   |  32 ++++++++++
>  drivers/net/dsa/bcm_sf2.c        |   2 +
>  include/net/dsa.h                |  33 ++++++++++
>  net/dsa/dsa_priv.h               |   3 +
>  net/dsa/slave.c                  | 135 ++++++++++++++++++++++++++++++++++++++-
>  7 files changed, 275 insertions(+), 1 deletion(-)
> 

-- 
Florian
