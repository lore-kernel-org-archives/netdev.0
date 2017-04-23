From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 1/1] drivers:net:ethernet:adi:bfin_mac: Use FIELD_SIZEOF
 defined kernel macro
Date: Sun, 23 Apr 2017 22:56:38 +0200
Message-ID: <CAMuHMdUo7GwRE5_o62+TDuut7y=WEpTxsq+Ys4KxAmGCFEb9ow@mail.gmail.com>
References: <1492970524-12607-1-git-send-email-karim.eshapa@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        Antonio Quartulli <a@unstable.cc>,
        Florian Westphal <fw@strlen.de>,
        LABBE Corentin <clabbe.montjoie@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Jarod Wilson <jarod@redhat.com>,
        "adi-buildroot-devel@lists.sourceforge.net"
        <adi-buildroot-devel@lists.sourceforge.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Karim Eshapa <karim.eshapa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33289 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1045923AbdDWU4k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 16:56:40 -0400
In-Reply-To: <1492970524-12607-1-git-send-email-karim.eshapa@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Karim,

On Sun, Apr 23, 2017 at 8:02 PM, Karim Eshapa <karim.eshapa@gmail.com> wrote:
> Use FIELD_SIZEOF defined kernel macro kernel.h
>
> Signed-off-by: Karim Eshapa <karim.eshapa@gmail.com>
> ---
>  drivers/net/ethernet/adi/bfin_mac.c | 14 +++++++++-----
>  1 file changed, 9 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
> index a9ac58c..60346e0 100644
> --- a/drivers/net/ethernet/adi/bfin_mac.c
> +++ b/drivers/net/ethernet/adi/bfin_mac.c
> @@ -452,10 +452,14 @@ static irqreturn_t bfin_mac_wake_interrupt(int irq, void *dev_id)
>  static void bfin_mac_ethtool_getdrvinfo(struct net_device *dev,
>                                         struct ethtool_drvinfo *info)
>  {
> -       strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
> -       strlcpy(info->version, DRV_VERSION, sizeof(info->version));
> -       strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
> -       strlcpy(info->bus_info, dev_name(&dev->dev), sizeof(info->bus_info));
> +       strlcpy(info->driver, KBUILD_MODNAME, FIELD_SIZEOF(
> +               struct ethtool_drvinfo, driver));

IMHO this makes the code less safe and less future-proof.
What if the type of info is ever changed?
There's no safety check to validate that the FIELD_SIZEOF() operates on the
same data as the strlcpy() destination.

> +       strlcpy(info->version, DRV_VERSION, FIELD_SIZEOF(
> +               struct ethtool_drvinfo, version));
> +       strlcpy(info->fw_version, "N/A", FIELD_SIZEOF(
> +               struct ethtool_drvinfo, fw_version));
> +       strlcpy(info->bus_info, dev_name(&dev->dev), FIELD_SIZEOF(
> +               struct ethtool_drvinfo, bus_info));
>  }
>
>  static void bfin_mac_ethtool_getwol(struct net_device *dev,
> @@ -785,7 +789,7 @@ static int bfin_mac_hwtstamp_get(struct net_device *netdev,
>         struct bfin_mac_local *lp = netdev_priv(netdev);
>
>         return copy_to_user(ifr->ifr_data, &lp->stamp_cfg,
> -                           sizeof(lp->stamp_cfg)) ?
> +                           FILD_SIZEOF(struct bfin_mac_local, stamp_cfg)) ?

As the kbuild test robot already told you, this doesn't compile.
Please try to (at least) compile the code before sending patches.
Thanks!

Gr{oetje,eeting}s,

                        Geert
