From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH 1/1] net: brcm80211: Deletion of unnecessary checks before
 two function calls
Date: Thu, 20 Nov 2014 19:04:26 +0100
Message-ID: <546E2D2A.6090101@broadcom.com>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net> <546E0DC8.3050906@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brett Rudley <brudley@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>,
	<brcm80211-dev-list@broadcom.com>, <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>,
	"Julia Lawall" <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:59404 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756854AbaKTSEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 13:04:30 -0500
In-Reply-To: <546E0DC8.3050906@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/20/14 16:50, SF Markus Elfring wrote:
> From: Markus Elfring<elfring@users.sourceforge.net>
> Date: Thu, 20 Nov 2014 16:42:51 +0100
>
> The functions brcmu_pkt_buf_free_skb() and release_firmware() test whether
> their argument is NULL and then return immediately. Thus the test around
> the call is not needed.
>
> This issue was detected by using the Coccinelle software.

Goodo for coccinelle and you for running it.

Acked-by: Arend van Spriel <arend@broadcom.com>
> Signed-off-by: Markus Elfring<elfring@users.sourceforge.net>
> ---
>   drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c | 3 +--
>   drivers/net/wireless/brcm80211/brcmfmac/firmware.c | 3 +--
>   drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c   | 3 +--
>   drivers/net/wireless/brcm80211/brcmsmac/main.c     | 3 +--
>   4 files changed, 4 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
> index f55f625..8ff7037 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
> @@ -2539,8 +2539,7 @@ static void brcmf_sdio_bus_stop(struct device *dev)
>   	brcmu_pktq_flush(&bus->txq, true, NULL, NULL);
>
>   	/* Clear any held glomming stuff */
> -	if (bus->glomd)
> -		brcmu_pkt_buf_free_skb(bus->glomd);
> +	brcmu_pkt_buf_free_skb(bus->glomd);
>   	brcmf_sdio_free_glom(bus);
>
>   	/* Clear rx control and wake any waiters */
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/firmware.c b/drivers/net/wireless/brcm80211/brcmfmac/firmware.c
> index 8ea9f28..3a2d014 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/firmware.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/firmware.c
> @@ -262,8 +262,7 @@ static void brcmf_fw_request_nvram_done(const struct firmware *fw, void *ctx)
>
>   fail:
>   	brcmf_dbg(TRACE, "failed: dev=%s\n", dev_name(fwctx->dev));
> -	if (fwctx->code)
> -		release_firmware(fwctx->code);
> +	release_firmware(fwctx->code);
>   	device_release_driver(fwctx->dev);
>   	kfree(fwctx);
>   }
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c b/drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c
> index 8f8b937..0cb00dc 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c
> @@ -506,8 +506,7 @@ static int brcmf_msgbuf_query_dcmd(struct brcmf_pub *drvr, int ifidx,
>   		memcpy(buf, skb->data, (len<  msgbuf->ioctl_resp_ret_len) ?
>   				       len : msgbuf->ioctl_resp_ret_len);
>   	}
> -	if (skb)
> -		brcmu_pkt_buf_free_skb(skb);
> +	brcmu_pkt_buf_free_skb(skb);
>
>   	return msgbuf->ioctl_resp_status;
>   }
> diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/wireless/brcm80211/brcmsmac/main.c
> index 1b47482..ce538a1 100644
> --- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
> +++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
> @@ -1009,8 +1009,7 @@ brcms_c_dotxstatus(struct brcms_c_info *wlc, struct tx_status *txs)
>   		if (txh)
>   			trace_brcms_txdesc(&wlc->hw->d11core->dev, txh,
>   					   sizeof(*txh));
> -		if (p)
> -			brcmu_pkt_buf_free_skb(p);
> +		brcmu_pkt_buf_free_skb(p);
>   	}
>
>   	if (dma&&  queue<  NFIFO) {
