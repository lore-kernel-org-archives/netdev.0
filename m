From: Gertjan van Wingerde <gwingerde@kpnplanet.nl>
Subject: Re: [PATCH] d80211: Only free WEP crypto ciphers when they have been
 allocated correctly.
Date: Sat, 06 Jan 2007 19:14:27 +0100
Message-ID: <459FE703.4080800@kpnplanet.nl>
References: <459FD5C4.9070301@kpnplanet.nl> <200701061229.16632.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from CPEXFE-VOIP04.KPNplanet.nl ([194.151.105.222]:55894 "EHLO
	cpexfe-voip04.KPNplanet.nl" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751445AbXAFSPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jan 2007 13:15:06 -0500
To: Michael Wu <flamingice@sourmilk.net>, Jiri Benc <jbenc@suse.cz>,
	netdev@vger.kernel.org
In-Reply-To: <200701061229.16632.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Wu wrote:
> On Saturday 06 January 2007 12:00, Gertjan van Wingerde wrote:
>   
>> The d80211 stack still tries to free the WEP crypto ciphers, even when
>> allocating them previously has failed. 
>>     
> Actually, the code might not even have tried to allocate them. The ciphers are 
> guaranteed to be allocated when the device is registered however, so we 
> should be able to free it safely on unregister.
>
> Signed-off-by: Michael Wu <flamingice@sourmilk.net>
> ---
>
>  net/d80211/ieee80211.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
> index 6e10db5..926d160 100644
> --- a/net/d80211/ieee80211.c
> +++ b/net/d80211/ieee80211.c
> @@ -4715,6 +4715,7 @@ void ieee80211_unregister_hw(struct ieee
>  	skb_queue_purge(&local->skb_queue_unreliable);
>  
>  	ieee80211_dev_free_index(local);
> +	ieee80211_wep_free(local);
>  	ieee80211_led_exit(local);
>  }
>  EXPORT_SYMBOL(ieee80211_unregister_hw);
> @@ -4724,7 +4725,6 @@ void ieee80211_free_hw(struct ieee80211_
>  	struct ieee80211_local *local = hw_to_local(hw);
>  
>  	ieee80211_if_free(local->mdev);
> -	ieee80211_wep_free(local);
>  	ieee80211_dev_free(local);
>  }
>  EXPORT_SYMBOL(ieee80211_free_hw);
OK. Your patch fixes the issue I've seen as well, and seems a bit cleaner.

Acked-by: Gertjan van Wingerde <gwingerde@kpnplanet.nl>
