From: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] brcm80211:Fix locking region in the function  brcmf_sdio_sendfromq
Date: Sun, 4 Oct 2015 22:54:37 +0200
Message-ID: <5611920D.60500@broadcom.com>
References: <1443889148-22678-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	<kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Nicholas Krause <xerofoify-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1443889148-22678-1-git-send-email-xerofoify-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/03/2015 06:19 PM, Nicholas Krause wrote:
> This fixes the locking region in the function brcmf_sdio_sendfromq
> to properly lock around the call to the function brcmrf_sdio_txpkt
> in order to avoid concurrent access issues when calling this
> function as stated in the function's comments about the caller
> being required to lock around the call to this particular function.
>
> Signed-off-by: Nicholas Krause <xerofoify-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>   drivers/net/wireless/brcm80211/brcmfmac/sdio.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
> index f990e3d..da59683 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
> @@ -2388,11 +2388,11 @@ static uint brcmf_sdio_sendfromq(struct brcmf_sdio *bus, uint maxframes)
>   				break;
>   			__skb_queue_tail(&pktq, pkt);
>   		}
> -		spin_unlock_bh(&bus->txq_lock);
>   		if (i == 0)
>   			break;

So what if we break here. Seems you need to do unlock if i == 0 here.

Regards,
Arend

>
>   		ret = brcmf_sdio_txpkt(bus, &pktq, SDPCM_DATA_CHANNEL);
> +		spin_unlock_bh(&bus->txq_lock);
>
>   		cnt += i;
>
>

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
