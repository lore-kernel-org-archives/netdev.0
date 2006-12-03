From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] softmac: fix unbalanced mutex_lock/unlock in ieee80211softmac_wx_set_mlme
Date: Sun, 03 Dec 2006 10:23:32 -0600
Message-ID: <4572FA04.6010906@lwfinger.net>
References: <20061203074203.GB5785@tralhalla.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:31936 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1755795AbWLCQXf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 11:23:35 -0500
To: Maxime Austruy <maxime@tralhalla.org>
In-Reply-To: <20061203074203.GB5785@tralhalla.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Maxime Austruy wrote:
> Found a hang while playing with wpa_supplicant and a zd1211 usb adapter
> using linux 2.6.19.  The problem is that ieee80211softmac_wx_set_mlme
> forgets to release a mutex when mlme->cmd is IW_MLME_DEAUTH.  The fix
> below allows me to kill wpa_supplicant and to restart it without having
> to reboot the machine. FWIW, it seems that the problem was introduced
> between 2.6.19-rc2 and 2.6.19-rc3 when this function was changed to use
> a mutex.
> 
> Signed-off-by: Maxime Austruy <maxime@tralhalla.org>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> 
> --
>  net/ieee80211/softmac/ieee80211softmac_wx.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> --- linux.orig/net/ieee80211/softmac/ieee80211softmac_wx.c	2006-11-29 13:57:37.000000000 -0800
> +++ linux/net/ieee80211/softmac/ieee80211softmac_wx.c	2006-12-02 22:58:20.000000000 -0800
> @@ -495,7 +495,8 @@ ieee80211softmac_wx_set_mlme(struct net_
>  			printk(KERN_DEBUG PFX "wx_set_mlme: we should know the net here...\n");
>  			goto out;
>  		}
> -		return ieee80211softmac_deauth_req(mac, net, reason);
> +		err =  ieee80211softmac_deauth_req(mac, net, reason);
> +		goto out;
>  	case IW_MLME_DISASSOC:
>  		ieee80211softmac_send_disassoc_req(mac, reason);
>  		mac->associnfo.associated = 0;
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

