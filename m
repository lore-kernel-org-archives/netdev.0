From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v2 3/6] stmmac: pci: Make stmmac_pci_find_phy_addr truly generic
Date: Sat, 27 May 2017 16:25:29 +0300
Message-ID: <CAHp75VdMB3pYBfvz40xZoDd8Ey162RN+moy3X2OZ_cBf3wW2rg@mail.gmail.com>
References: <cover.1495814872.git.jan.kiszka@siemens.com> <61af7f05bb92da3220ed5799dfa5bb84e102f067.1495814872.git.jan.kiszka@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jan Kiszka <jan.kiszka@siemens.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:35211 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756626AbdE0NZb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 09:25:31 -0400
In-Reply-To: <61af7f05bb92da3220ed5799dfa5bb84e102f067.1495814872.git.jan.kiszka@siemens.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 26, 2017 at 7:07 PM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
> Move the special case for the early Galileo firmware into
> quark_default_setup. This allows to use stmmac_pci_find_phy_addr for
> non-quark cases.

>         ret = stmmac_pci_find_phy_addr(pdev, info);
> -       if (ret < 0)
> -               return ret;
> +       if (ret < 0) {
> +               /*
> +                * Galileo boards with old firmware don't support DMI. We always
> +                * use 1 here as PHY address, so at least the first found MAC
> +                * controller would be probed.
> +                */
> +               if (!dmi_get_system_info(DMI_BOARD_NAME))
> +                       ret = 1;
> +               else
> +                       return ret;

Perhaps

/* Return error to the caller on DMI enabled boards */
if (dmi_...)
 return ret;
/*
 * Comment goes here, I suppose.
 */
ret = 1;

> +       }

-- 
With Best Regards,
Andy Shevchenko
