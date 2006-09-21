From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH]d80211: fix "iwconfig key [x]" behavior
Date: Thu, 21 Sep 2006 17:51:04 +0200
Message-ID: <20060921175104.31429d65@logostar.upir.cz>
References: <1156754199.6061.3.camel@devlinux-hong>
	<20060830192452.6ae099d5@griffin.suse.cz>
	<1157081877.11040.44.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:18593 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751274AbWIUPvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 11:51:11 -0400
To: Hong Liu <hong.liu@intel.com>
In-Reply-To: <1157081877.11040.44.camel@devlinux-hong>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

sorry for the delay.

On Fri, 01 Sep 2006 11:37:57 +0800, Hong Liu wrote:
> @@ -2925,7 +2932,8 @@ static int ieee80211_ioctl_giwencode(str
>  		return 0;
>  	}
>  
> -	erq->length = 0;
> +	erq->length = min((int)erq->length, sdata->keys[idx]->keylen);
> +	memcpy(key, sdata->keys[idx]->key, erq->length);
>  	erq->flags |= IW_ENCODE_ENABLED;
>  
>  	return 0;

This is still not correct, erq->length should be set to the actual key
length to allow WE to return -E2BIG in case of too small buffer.

	memcpy(key, sdata->keys[idx]->key,
	       min((int)erq->length, sdata->keys[idx]->keylen));
	erq->length = sdata->keys[idx]->keylen;

 Jiri

-- 
Jiri Benc
SUSE Labs
