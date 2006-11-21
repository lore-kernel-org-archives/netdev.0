From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: RFC/T: Trial fix for the bcm43xx - wpa_supplicant - NetworkManager
	deadlock
Date: Tue, 21 Nov 2006 10:30:59 -0600
Message-ID: <456329C3.1040504@lwfinger.net>
References: <4561DBE0.2060908@lwfinger.net> <200611210017.47695.mb@bu3sch.de>
	<1164098989.2769.9.camel@ux156> <200611210959.17644.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Joseph Fannin <jhf-rN3PHIWzTs1Jm/Hvfsr4+Q@public.gmane.org>, Ray Lee <ray-lk-0Cg02Ec9UG4BXFe83j6qeQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
In-Reply-To: <200611210959.17644.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Tuesday 21 November 2006 09:49, Johannes Berg wrote:
>> On Tue, 2006-11-21 at 00:17 +0100, Michael Buesch wrote:
>>
>>> So, how to fix this?
>>> Actually, do we even _have_ to disable TX when scanning? I'd say no.
>>> Opinions?
>> For active scanning we can't disable TX. And for passive scanning the
>> firmware will block unwanted frames from going out on the wrong
>> channel :)
> 
> 
> Ok, so people, please do test this patch.
> I did not test it myself, but I am pretty sure it will fix
> a lot of mysterious and unobvious bugs people are seeing.

I put the equivalent into my system about 12 hours ago and have not seen any problems.

Larry

> 
> Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
> 
> Index: wireless-2.6/net/ieee80211/softmac/ieee80211softmac_scan.c
> ===================================================================
> --- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_scan.c	2006-09-27 19:34:20.000000000 +0200
> +++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_scan.c	2006-11-21 09:57:14.000000000 +0100
> @@ -47,7 +47,6 @@ ieee80211softmac_start_scan(struct ieee8
>  	sm->scanning = 1;
>  	spin_unlock_irqrestore(&sm->lock, flags);
>  
> -	netif_tx_disable(sm->ieee->dev);
>  	ret = sm->start_scan(sm->dev);
>  	if (ret) {
>  		spin_lock_irqsave(&sm->lock, flags);
> @@ -248,7 +247,6 @@ void ieee80211softmac_scan_finished(stru
>  		if (net)
>  			sm->set_channel(sm->dev, net->channel);
>  	}
> -	netif_wake_queue(sm->ieee->dev);
>  	ieee80211softmac_call_events(sm, IEEE80211SOFTMAC_EVENT_SCAN_FINISHED, NULL);
>  }
>  EXPORT_SYMBOL_GPL(ieee80211softmac_scan_finished);
> 
> 
