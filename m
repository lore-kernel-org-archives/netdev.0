From: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] brcmfmac: fix error handling of irq_of_parse_and_map
Date: Sun, 16 Nov 2014 14:02:14 +0100
Message-ID: <5468A056.9030200@broadcom.com>
References: <20141114221221.GA35541@dtor-ws>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Franky (Zhenhui) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Pieter-Paul Giesberts <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Dmitry Torokhov <dtor-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141114221221.GA35541@dtor-ws>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/14/14 23:12, Dmitry Torokhov wrote:
> Return value of irq_of_parse_and_map() is unsigned int, with 0
> indicating failure, so testing for negative result never works.

Whoops, that is bad. Thanks for catching this. It probably needs to go 
to stable as well for 3.17 kernel.

+Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org # v3.17
+Acked-by: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Dmitry Torokhov<dtor-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> ---
>
> Not tested, found by casual code inspection.
>
>   drivers/net/wireless/brcm80211/brcmfmac/of.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/of.c b/drivers/net/wireless/brcm80211/brcmfmac/of.c
> index eb3fce82..c824570 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/of.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/of.c
> @@ -40,8 +40,8 @@ void brcmf_of_probe(struct brcmf_sdio_dev *sdiodev)
>   		return;
>
>   	irq = irq_of_parse_and_map(np, 0);
> -	if (irq<  0) {
> -		brcmf_err("interrupt could not be mapped: err=%d\n", irq);
> +	if (!irq) {
> +		brcmf_err("interrupt could not be mapped\n");
>   		devm_kfree(dev, sdiodev->pdata);
>   		return;
>   	}

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
