From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/4] net: dsa: Port mirroring support
Date: Fri, 27 Jan 2017 16:52:53 -0800
Message-ID: <0345838c-dc61-3ce6-eed2-71b29be1cedc@gmail.com>
References: <20170128004035.26035-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, cphealy@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34530 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750789AbdA1Aw4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 19:52:56 -0500
Received: by mail-pg0-f67.google.com with SMTP id 3so8414725pgj.1
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 16:52:55 -0800 (PST)
In-Reply-To: <20170128004035.26035-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/27/2017 04:40 PM, Florian Fainelli wrote:
> Hi all,
> 
> This patch series adds support for port mirroring in the two
> Broadcom switch drivers. The major part of the functional are actually with
> the plumbing between tc and the drivers.

Meh, there are two issues that need fixing:

- left a stray list_head in the dsa_port structure which we do not need
- if we remove either the ingress, or egress filter, we end-up disabling
the mirroring entirely, so need to rework the b53_mirror_del logic a bit

Will re-submit shortly.

> 
> David, this will most likely conflict a little bit with my other series:
>  net: dsa: bcm_sf2: CFP support, so just let me know if that happens, and
> I will provide a rebased version. Thanks!
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
>  drivers/net/dsa/b53/b53_common.c |  54 +++++++++++++++
>  drivers/net/dsa/b53/b53_priv.h   |   4 ++
>  drivers/net/dsa/b53/b53_regs.h   |  32 +++++++++
>  drivers/net/dsa/bcm_sf2.c        |   2 +
>  include/net/dsa.h                |  41 +++++++++++
>  net/dsa/dsa_priv.h               |   3 +
>  net/dsa/slave.c                  | 143 ++++++++++++++++++++++++++++++++++++++-
>  7 files changed, 278 insertions(+), 1 deletion(-)
> 


-- 
Florian
