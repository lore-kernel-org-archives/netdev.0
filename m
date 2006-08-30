From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH]d80211: fix "iwconfig key [x]" behavior
Date: Wed, 30 Aug 2006 19:24:52 +0200
Message-ID: <20060830192452.6ae099d5@griffin.suse.cz>
References: <1156754199.6061.3.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:62437 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751200AbWH3RYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 13:24:54 -0400
To: Hong Liu <hong.liu@intel.com>
In-Reply-To: <1156754199.6061.3.camel@devlinux-hong>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 28 Aug 2006 16:36:39 +0800, Hong Liu wrote:
> "iwconfig key [x]" behavior is not correctly handled in the stack, also
> modify the giwencode method to show the key info.

Thanks for spotting and fixing these bugs!

> @@ -2869,7 +2877,8 @@ static int ieee80211_ioctl_giwencode(str
>  		return 0;
>  	}
>  
> -	erq->length = 0;
> +	erq->length = sdata->keys[idx]->keylen;
> +	memcpy(key, sdata->keys[idx]->key, erq->length);

Shouldn't there be a check for buffer size here?

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
