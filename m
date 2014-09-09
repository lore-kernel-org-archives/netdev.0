From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v5 11/13] net: dsa: add Broadcom SF2 switch driver
Date: Tue, 9 Sep 2014 12:37:51 -0700
Message-ID: <CAKgT0UfQuvzzCWeD7DCfsf4O+0jBJ4DeQg0kUfd06Ar33GXu7w@mail.gmail.com>
References: <1409184298-1793-1-git-send-email-f.fainelli@gmail.com>
	<1409184298-1793-12-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	John Linville <linville@tuxdriver.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:38832 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787AbaIIThv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 15:37:51 -0400
Received: by mail-ig0-f181.google.com with SMTP id h15so5142678igd.8
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 12:37:51 -0700 (PDT)
In-Reply-To: <1409184298-1793-12-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 27, 2014 at 5:04 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Add support for the Broadcom Starfigther 2 switch chip using a DSA
> driver. This switch driver supports the following features:
>
> - configuration of the external switch port interface: MII, RevMII,
>   RGMII and RGMII_NO_ID are supported
> - support for the per-port MIB counters
> - support for link interrupts for special ports (e.g: MoCA)
> - powering up/down of switch memories to conserve power when ports are
>   unused
>
> Finally, update the compatible property for the DSA core code to match
> our switch top-level compatible node.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Changes in v4:
> - fixed typo on the word Starfighter
> - fixed a few checkpatch.pl warnings
>
> No changes in v3
>
> Changes in v2:
> - add support for reading to special MDIO phys (0 and 30)
> - added more power down optimization
> - added VLAN separation
>
>  drivers/net/dsa/Kconfig        |  11 +
>  drivers/net/dsa/Makefile       |   1 +
>  drivers/net/dsa/bcm_sf2.c      | 626 +++++++++++++++++++++++++++++++++++++++++
>  drivers/net/dsa/bcm_sf2.h      | 140 +++++++++
>  drivers/net/dsa/bcm_sf2_regs.h | 227 +++++++++++++++
>  net/dsa/dsa.c                  |   1 +
>  6 files changed, 1006 insertions(+)
>  create mode 100644 drivers/net/dsa/bcm_sf2.c
>  create mode 100644 drivers/net/dsa/bcm_sf2.h
>  create mode 100644 drivers/net/dsa/bcm_sf2_regs.h

[...]

> diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
> new file mode 100644
> index 000000000000..bb7cb8e283b1
> --- /dev/null
> +++ b/drivers/net/dsa/bcm_sf2.c

[...]

> +static char *bcm_sf2_sw_probe(struct mii_bus *bus, int sw_addr)
> +{
> +       return "Broadcom Starfighter 2";
> +}
> +

I hadn't noticed before but with this driver it seems like you could
potentially load on any DSA enabled device could you not?  It seems
like this would be problematic since you could end up registering
before another DSA driver and prevent it from being able to load since
you always return success.  Isn't there any test you could run to
determine if the switch is actually there or not?

Thanks,

Alex
