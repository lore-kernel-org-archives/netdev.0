From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] staging: r8712u: Fix kernel warning for improper call
 of del_timer_sync()
Date: Mon, 25 May 2015 11:02:27 -0500
Message-ID: <55634793.4050002@lwfinger.net>
References: <1432415812-1285-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	linux-wireless@vger.kernel.org, Stable <stable@vger.kernel.org>,
	Haggi Eran <haggai.eran@gmail.com>
To: gregkh@linuxfoundation.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1432415812-1285-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/23/2015 04:16 PM, Larry Finger wrote:
> The driver is reporting a warning at kernel/time/timer.c:1096 due to calling
> del_timer_sync() while in interrupt mode. Such warnings are fixed by calling
> del_timer() instead.
>
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Stable <stable@vger.kernel.org>
> Cc: Haggi Eran <haggai.eran@gmail.com>
> ---

Greg,

Please drop this patch. The same fixes were submitted as 
https://lkml.org/lkml/2015/5/15/226.

It is crucial that this get into the 4.1 kernel where the regression was introduced.

Larry

>   drivers/staging/rtl8712/rtl8712_led.c  | 2 +-
>   drivers/staging/rtl8712/rtl871x_mlme.c | 4 ++--
>   2 files changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/staging/rtl8712/rtl8712_led.c b/drivers/staging/rtl8712/rtl8712_led.c
> index f1d47a0..8cc716c 100644
> --- a/drivers/staging/rtl8712/rtl8712_led.c
> +++ b/drivers/staging/rtl8712/rtl8712_led.c
> @@ -921,7 +921,7 @@ static void SwLedControlMode1(struct _adapter *padapter,
>   			    IS_LED_WPS_BLINKING(pLed))
>   				return;
>   			if (pLed->bLedNoLinkBlinkInProgress == true) {
> -				del_timer_sync(&pLed->BlinkTimer);
> +				del_timer(&pLed->BlinkTimer);
>   				pLed->bLedNoLinkBlinkInProgress = false;
>   			}
>   			if (pLed->bLedBlinkInProgress == true) {
> diff --git a/drivers/staging/rtl8712/rtl871x_mlme.c b/drivers/staging/rtl8712/rtl871x_mlme.c
> index fb2b195..ace88ab 100644
> --- a/drivers/staging/rtl8712/rtl871x_mlme.c
> +++ b/drivers/staging/rtl8712/rtl871x_mlme.c
> @@ -582,7 +582,7 @@ void r8712_surveydone_event_callback(struct _adapter *adapter, u8 *pbuf)
>   	spin_lock_irqsave(&pmlmepriv->lock, irqL);
>
>   	if (check_fwstate(pmlmepriv, _FW_UNDER_SURVEY) == true) {
> -		del_timer_sync(&pmlmepriv->scan_to_timer);
> +		del_timer(&pmlmepriv->scan_to_timer);
>
>   		_clr_fwstate_(pmlmepriv, _FW_UNDER_SURVEY);
>   	}
> @@ -910,7 +910,7 @@ void r8712_joinbss_event_callback(struct _adapter *adapter, u8 *pbuf)
>   			if (check_fwstate(pmlmepriv, WIFI_STATION_STATE)
>   				== true)
>   				r8712_indicate_connect(adapter);
> -			del_timer_sync(&pmlmepriv->assoc_timer);
> +			del_timer(&pmlmepriv->assoc_timer);
>   		} else
>   			goto ignore_joinbss_callback;
>   	} else {
>
