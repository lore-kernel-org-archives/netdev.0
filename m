From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: Re: [PATCH] 6lowpan: fix assignment of peer_addr
Date: Tue, 28 Mar 2017 16:32:37 +0300
Message-ID: <CABBYNZ+cnZZPS9juCJE4F9X6rfXRHRHp-TNiV3dxE_dpDbe-=w@mail.gmail.com>
References: <20170328121129.18421-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        "linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
        "open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170328121129.18421-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Colin,

On Tue, Mar 28, 2017 at 3:11 PM, Colin King <colin.king@canonical.com> wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> The data from peer->chan->dst is not being copied to peer_addr, the
> current code just updates the pointer and not the contents of what
> it points to.  Fix this with the intended assignment.
>
> Detected by CoverityScan, CID#1422111 ("Parse warning
> (PW.PARAM_SET_BUT_NOT_USED)")
>
> Fixes: fb6f2f606ce8 ("6lowpan: Fix IID format for Bluetooth")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  net/bluetooth/6lowpan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
> index 24348c8579dd..ba28c7b1557f 100644
> --- a/net/bluetooth/6lowpan.c
> +++ b/net/bluetooth/6lowpan.c
> @@ -432,7 +432,7 @@ static int setup_header(struct sk_buff *skb, struct net_device *netdev,
>                 }
>
>                 daddr = peer->lladdr;
> -               peer_addr = &peer->chan->dst;
> +               *peer_addr = peer->chan->dst;
>                 *peer_addr_type = peer->chan->dst_type;
>                 lowpan_cb(skb)->chan = peer->chan;
>
> --
> 2.11.0

Reviewed-by: Luiz Augusto von Dentz <luiz.von.dentz@intel.com>

-- 
Luiz Augusto von Dentz
