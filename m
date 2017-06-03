From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v2] brcmfmac: Fix glom_skb leak in brcmf_sdiod_recv_chain
Date: Sat, 3 Jun 2017 18:36:34 +0300
Message-ID: <CAHp75VcfK5V42vzsh=L+CnX2ZnF=8UORbOf+f2WfmcNH1DbAsw@mail.gmail.com>
References: <CA+8PC_e8HdkBw4DfGUPO0BbM-W5wftK=i6_vjwFTmS7=axyFUw@mail.gmail.com>
 <1496442569-11307-1-git-send-email-housel@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        Christian Daudt <csd@broadcom.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Florian Westphal <fw@strlen.de>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        "open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
        <linux-wireless@vger.kernel.org>,
        "open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
        <brcm80211-dev-list.pdl@broadcom.com>,
        "open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
To: "Peter S. Housel" <housel@acm.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496442569-11307-1-git-send-email-housel@acm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 3, 2017 at 1:29 AM, Peter S. Housel <housel@acm.org> wrote:
> An earlier change to this function (3bdae810721b) fixed a leak in the
> case of an unsuccessful call to brcmf_sdiod_buffrw(). However, the
> glom_skb buffer, used for emulating a scattering read, is never used
> or referenced after its contents are copied into the destination
> buffers, and therefore always needs to be freed by the end of the
> function.

>                 err = brcmf_sdiod_buffrw(sdiodev, SDIO_FUNC_2, false, addr,
>                                          glom_skb);
> -               if (err) {
> -                       brcmu_pkt_buf_free_skb(glom_skb);
> -                       goto done;
> -               }
> -
> -               skb_queue_walk(pktq, skb) {
> -                       memcpy(skb->data, glom_skb->data, skb->len);
> -                       skb_pull(glom_skb, skb->len);

> +               if (!err) {

This is not so often in use type of pattern.

> +                       skb_queue_walk(pktq, skb) {
> +                               memcpy(skb->data, glom_skb->data, skb->len);
> +                               skb_pull(glom_skb, skb->len);
> +                       }
>                 }

> +               brcmu_pkt_buf_free_skb(glom_skb);

Can we just add this one line instead or I'm missing something?

>         } else
>                 err = brcmf_sdiod_sglist_rw(sdiodev, SDIO_FUNC_2, false, addr,
>                                             pktq);



-- 
With Best Regards,
Andy Shevchenko
