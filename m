From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 1/13] d80211: clean up some stupid list and loop code
Date: Mon, 20 Nov 2006 12:01:33 +0100
Message-ID: <20061120120133.75182913@griffin.suse.cz>
References: <1163802439.3392.47.camel@johannes.berg>
	<1163963898.15473.36.camel@johannes.berg>
	<1163964140.15473.39.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeus1.kernel.org ([204.152.191.4]:19615 "EHLO zeus1.kernel.org")
	by vger.kernel.org with ESMTP id S1755879AbWKTLFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 06:05:35 -0500
Received: from mail.suse.cz (styx.suse.cz [82.119.242.94])
	by zeus1.kernel.org (8.13.8/8.13.1) with ESMTP id kAKB25KP015605
	for <netdev@vger.kernel.org>; Mon, 20 Nov 2006 11:02:20 GMT
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1163964140.15473.39.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 19 Nov 2006 20:22:20 +0100, Johannes Berg wrote:
> --- wireless-dev.orig/net/d80211/sta_info.c	2006-11-19 20:13:52.339275208 +0100
> +++ wireless-dev/net/d80211/sta_info.c	2006-11-19 20:13:54.119275208 +0100
> @@ -324,16 +324,13 @@ static void sta_info_cleanup_expire_buff
>  static void sta_info_cleanup(unsigned long data)
>  {
>  	struct ieee80211_local *local = (struct ieee80211_local *) data;
> -	struct list_head *ptr;
> +	struct sta_info *sta, *tmp;
>  
>  	spin_lock_bh(&local->sta_lock);
> -	ptr = local->sta_list.next;
> -	while (ptr && ptr != &local->sta_list) {
> -		struct sta_info *sta = (struct sta_info *) ptr;
> +	list_for_each_entry_safe(sta, tmp, &local->sta_list, list) {

There is no need for _safe here.

>  		__sta_info_get(sta);
>  		sta_info_cleanup_expire_buffered(local, sta);
>  		sta_info_put(sta);
> -		ptr = ptr->next;
>  	}
>  	spin_unlock_bh(&local->sta_lock);
>  

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
