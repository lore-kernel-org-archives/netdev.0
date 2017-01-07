From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v4] net: stmmac: fix maxmtu assignment to be within valid range
Date: Sat, 7 Jan 2017 02:12:23 +0200
Message-ID: <CAHp75VeBJsTR9OrdYQqs7fCb40KzyByehX97VdKm8CerDUwVqg@mail.gmail.com>
References: <1483776634-13095-1-git-send-email-hock.leong.kweh@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        seraphin.bonnaffe@st.com, Jarod Wilson <jarod@redhat.com>,
        Alexandre TORGUE <alexandre.torgue@gmail.com>,
        Joachim Eastwood <manabian@gmail.com>,
        Niklas Cassel <niklas.cassel@axis.com>,
        Johan Hovold <johan@kernel.org>, Pavel Machek <pavel@ucw.cz>,
        lars.persson@axis.com, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:36707 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750853AbdAGAMZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 19:12:25 -0500
In-Reply-To: <1483776634-13095-1-git-send-email-hock.leong.kweh@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 7, 2017 at 10:10 AM, Kweh, Hock Leong
<hock.leong.kweh@intel.com> wrote:
> From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
>
> There is no checking valid value of maxmtu when getting it from device tree.
> This resolution added the checking condition to ensure the assignment is
> made within a valid range.

> changelog v4:
> * add print warning message when maxmtu > max_mtu as well

Yep.

> * add maxmtu = JUMBO_LEN into each *_default_data() at stmmac_pci.c

Yep.

But see comment below.

P.S. And perhaps next time send into our internal mailing list first for review.

> @@ -3345,8 +3345,14 @@ int stmmac_dvr_probe(struct device *device,
>                 ndev->max_mtu = JUMBO_LEN;
>         else
>                 ndev->max_mtu = SKB_MAX_HEAD(NET_SKB_PAD + NET_IP_ALIGN);
> -       if (priv->plat->maxmtu < ndev->max_mtu)
> +       if ((priv->plat->maxmtu < ndev->max_mtu) &&
> +           (priv->plat->maxmtu >= ndev->min_mtu))
>                 ndev->max_mtu = priv->plat->maxmtu;

> +       else if ((priv->plat->maxmtu < ndev->min_mtu) ||
> +                (priv->plat->maxmtu > ndev->max_mtu))
> +               netdev_warn(priv->dev,

What is the difference to just 'else'? (Returning back to my initial
proposal, I don't remember telling anything about 'else if' concept)

> +                           "%s: warning: maxmtu having invalid value (%d)\n",
> +                           __func__, priv->plat->maxmtu);

-- 
With Best Regards,
Andy Shevchenko
