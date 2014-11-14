From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH] brcmfmac: kill URB when request timed out
Date: Fri, 14 Nov 2014 09:57:04 +0100
Message-ID: <5465C3E0.3070402@broadcom.com>
References: <5464187E.5060208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Mathy Vanhoef <vanhoefm@gmail.com>, <brudley@broadcom.com>,
	<frankyl@broadcom.com>, <meuleman@broadcom.com>,
	John Linville <linville@tuxdriver.com>,
	<pieterpg@broadcom.com>, <linux-wireless@vger.kernel.org>,
	<brcm80211-dev-list@broadcom.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:64233 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964989AbaKNI5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 03:57:09 -0500
In-Reply-To: <5464187E.5060208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-11-14 03:33, Mathy Vanhoef wrote:
> Kill the submitted URB in brcmf_usb_dl_cmd if the request timed out. This
> assures the URB is never submitted twice. It also prevents a possible
> use-after-free of the URB transfer buffer if a timeout occurs.
> 
Acked-by: Arend van Spriel <arend@broadcom.com>
> Signed-off-by: Mathy Vanhoef <vanhoefm@gmail.com>
> ---
> For a discussion about this patch and the underlying problem, see the mails
> with as subject "[PATCH] brcmfmac: unlink URB when request timed out".
> 
>  drivers/net/wireless/brcm80211/brcmfmac/usb.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/usb.c b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
> index 5265aa7..4572def 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/usb.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
> @@ -738,10 +738,12 @@ static int brcmf_usb_dl_cmd(struct brcmf_usbdev_info *devinfo, u8 cmd,
>  		goto finalize;
>  	}
>  
> -	if (!brcmf_usb_ioctl_resp_wait(devinfo))
> +	if (!brcmf_usb_ioctl_resp_wait(devinfo)) {
> +		usb_kill_urb(devinfo->ctl_urb);
>  		ret = -ETIMEDOUT;
> -	else
> +	} else {
>  		memcpy(buffer, tmpbuf, buflen);
> +	}
>  
>  finalize:
>  	kfree(tmpbuf);
> 
