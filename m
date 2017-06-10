From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH net-next] net: fec: Clear and enable MIB counters on imx51
Date: Fri, 9 Jun 2017 22:12:59 -0300
Message-ID: <CAOMZO5A1hh=6npHGkK8Y+0F_ta+Kr-5OxRdqyqmma_xis84WqA@mail.gmail.com>
References: <1496800629-24910-1-git-send-email-andrew@lunn.ch>
 <20170607.100742.9158707718791478.davem@davemloft.net> <CAP=VYLr4_jjiXs8bD+9LU3TvEmmJqcU=MRFaKV-Co12mYNE0WA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>, Andrew Lunn <andrew@lunn.ch>,
        netdev <netdev@vger.kernel.org>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Chris Healy <cphealy@gmail.com>,
        "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <CAP=VYLr4_jjiXs8bD+9LU3TvEmmJqcU=MRFaKV-Co12mYNE0WA@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paul,

On Fri, Jun 9, 2017 at 10:01 PM, Paul Gortmaker
<paul.gortmaker@windriver.com> wrote:

> Seems to break one of the automated linux-next builds:
>
> http://kisskb.ellerman.id.au/kisskb/buildresult/13057702/
>
> A mindless automated bisect reports:
>
> 2b30842b23b9e6796c7bd5f0916fd2ebf6b7d633 is the first bad commit
> commit 2b30842b23b9e6796c7bd5f0916fd2ebf6b7d633
> Author: Andrew Lunn <andrew@lunn.ch>
> Date:   Wed Jun 7 03:57:09 2017 +0200
>
>     net: fec: Clear and enable MIB counters on imx51

This should fix it:

--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2379,6 +2379,10 @@ static void fec_enet_clear_ethtool_stats(struct
net_device *dev)
 static inline void fec_enet_update_ethtool_stats(struct net_device *dev)
 {
 }
+
+static inline void fec_enet_clear_ethtool_stats(struct net_device *dev)
+{
+}
 #endif /* !defined(CONFIG_M5272) */

 /* ITR clock source is enet system clock (clk_ahb).

Will test it and submit a formal patch in case it works.

Thanks
