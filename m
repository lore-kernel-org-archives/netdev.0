From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH] net: stmmac: ensure jumbo_frm error return is correctly
 checked for -ve value
Date: Sat, 3 Jun 2017 18:55:57 +0300
Message-ID: <CAHp75VeuumsZHDdue=n-2esyG7Q-6472JoYJ64U0+OQoC2psgQ@mail.gmail.com>
References: <20170602145827.21151-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev <netdev@vger.kernel.org>, kernel-janitors@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170602145827.21151-1-colin.king@canonical.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 2, 2017 at 5:58 PM, Colin King <colin.king@canonical.com> wrote:
> The current comparison of entry < 0 will never be true since entry is an
> unsigned integer. Cast entry to an int to ensure -ve error return values
> from the call to jumbo_frm are correctly being caught.

>         if (unlikely(is_jumbo) && likely(priv->synopsys_id <
>                                          DWMAC_CORE_4_00)) {
>                 entry = priv->hw->mode->jumbo_frm(tx_q, skb, csum_insertion);
> -               if (unlikely(entry < 0))
> +               if (unlikely((int)entry < 0))

It feels like a hiding some other issue.

-- 
With Best Regards,
Andy Shevchenko
