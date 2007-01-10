From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] d80211: don't symlink empty default keys
Date: Wed, 10 Jan 2007 20:40:29 +0100
Message-ID: <20070110204029.014cc96d@griffin.suse.cz>
References: <45A4183E.4010401@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ivo Van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:35605 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965052AbXAJTkb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 14:40:31 -0500
To: Jan Kiszka <jan.kiszka@web.de>
In-Reply-To: <45A4183E.4010401@web.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 09 Jan 2007 23:33:34 +0100, Jan Kiszka wrote:
> This gets rid of annoying
> 
> wlan0: cannot create symlink to default key
> 
> in my syslog with latest rt2x00. The patch takes care that in case of
> (key/old_key == NULL && set_tx_key) the existing default key symlink is
> removed correctly. Moreover, it tests for key!=NULL before trying to register
> a new default link.
> 
> Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
> 
> ---
>  ieee80211/ieee80211_ioctl.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> Index: rt2x00/ieee80211/ieee80211_ioctl.c
> ===================================================================
> --- rt2x00.orig/ieee80211/ieee80211_ioctl.c
> +++ rt2x00/ieee80211/ieee80211_ioctl.c
> @@ -629,7 +629,7 @@ static int ieee80211_set_encryption(stru
>  		}
>  		kfree(keyconf);
>  
> -		if (key && sdata->default_key == key) {
> +		if (set_tx_key || (key && sdata->default_key == key)) {
>  			ieee80211_key_sysfs_remove_default(sdata);

This is not correct when set_tx_key is set and sdata->default_key is
NULL.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
