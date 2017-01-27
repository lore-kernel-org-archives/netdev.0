From: Chris Healy <cphealy@gmail.com>
Subject: Re: [PATCH net-next 0/4] net: dsa: bcm_sf2: CFP support
Date: Fri, 27 Jan 2017 13:24:15 -0800
Message-ID: <CAFXsbZohZy3ybi6Pe5hryGfuBPnstUAQpB0HM4++XFmwbYi+3w@mail.gmail.com>
References: <20170127210516.16704-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36774 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751774AbdA0Vat (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 16:30:49 -0500
Received: by mail-io0-f195.google.com with SMTP id q20so9220505ioi.3
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 13:30:49 -0800 (PST)
In-Reply-To: <20170127210516.16704-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

In saying the below, I may just be showing my naivety but here goes:

If I understand this correctly, what you are using is similar to the
TCAM hardware present in the newer Marvell switches.  I think Pablo is
doing some work with nftables and HW offload using TCAM HW.  Is there
overlap here?  It seems that one or the other API should be used but
not both.

Regards,

Chris

On Fri, Jan 27, 2017 at 1:05 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Hi all,
>
> This patch series adds support for the Broadcom Compact Field Processor (CFP)
> which is a classification and matching engine built into most Broadcom switches.
>
> We support that using ethtool::rxnfc because it allows all known uses cases from
> the users I support to work, and more importantly, it allows the selection of a
> target rule index, which is later used by e.g: offloading hardware, this is an
> essential feature that I could not find being supported with cls_* for instance.
>
> Thanks
>
> Florian Fainelli (4):
>   net: dsa: Hook {get,set}_rxnfc ethtool operations
>   net: dsa: bcm_sf2: Configure traffic classes to queue mapping
>   net: dsa: bcm_sf2: Add CFP registers definitions
>   net: dsa: bcm_sf2: Add support for ethtool::rxnfc
>
>  drivers/net/dsa/Makefile       |   2 +-
>  drivers/net/dsa/bcm_sf2.c      |  23 ++
>  drivers/net/dsa/bcm_sf2.h      |  17 ++
>  drivers/net/dsa/bcm_sf2_cfp.c  | 613 +++++++++++++++++++++++++++++++++++++++++
>  drivers/net/dsa/bcm_sf2_regs.h | 150 ++++++++++
>  include/net/dsa.h              |   8 +
>  net/dsa/slave.c                |  26 ++
>  7 files changed, 838 insertions(+), 1 deletion(-)
>  create mode 100644 drivers/net/dsa/bcm_sf2_cfp.c
>
> --
> 2.9.3
>
