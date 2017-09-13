From: Allen <allen.lkml@gmail.com>
Subject: Re: [PATCH 06/10] drivers:ethernet: return -ENOMEM on allocation failure.
Date: Wed, 13 Sep 2017 18:34:17 +0530
Message-ID: <CAOMdWS+mOcm=6722SD=-SvfD59AeXpwAARLhT31UycQSqWTxdg@mail.gmail.com>
References: <1505287939-14106-1-git-send-email-allen.lkml@gmail.com>
 <1505287939-14106-6-git-send-email-allen.lkml@gmail.com> <20170913121628.GB11820@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-kernel@vger.kernel.org, nouveau@lists.freedesktop.org,
        linux-crypto@vger.kernel.org, dri-devel@lists.freedesktop.org,
        MPT-FusionLinux.pdl@broadcom.com, linux-scsi@vger.kernel.org,
        netdev@vger.kernel.org, megaraidlinux.pdl@broadcom.com,
        target-devel@vger.kernel.org, linux-fbdev@vger.kernel.org,
        linux-btrfs@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20170913121628.GB11820@lunn.ch>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>
> static int cas_alloc_rxds(struct cas *cp)
> {
>         int i;
>
>         for (i = 0; i < N_RX_DESC_RINGS; i++) {
>                 if (cas_alloc_rx_desc(cp, i) < 0) {
>                         cas_free_rxds(cp);
>                         return -1;
>                 }
>         }
>         return 0;
> }
>
> Again, your change is correct, but in the end the value is not used.
> And if you fix it at the cas_alloc_rxds level, you also need a fix at
> the next level up:
>
>         err = -ENOMEM;
>         if (cas_tx_tiny_alloc(cp) < 0)
>                 goto err_unlock;
>
>         /* alloc rx descriptors */
>         if (cas_alloc_rxds(cp) < 0)
>                 goto err_tx_tiny;
>
> again, the return value is discarded.

 I agree. I could send out v2 with fixes at both level.

- Allen
