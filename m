From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 4/13] d80211: reduce mdev usage, change
 ieee80211_rx_mgmt
Date: Mon, 20 Nov 2006 13:08:59 +0100
Message-ID: <20061120130859.329993c8@griffin.suse.cz>
References: <1163802439.3392.47.camel@johannes.berg>
	<1163963898.15473.36.camel@johannes.berg>
	<1163964402.15473.47.camel@johannes.berg>
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
Received: from styx.suse.cz ([82.119.242.94]:5066 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S934098AbWKTMJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 07:09:02 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1163964402.15473.47.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 19 Nov 2006 20:26:41 +0100, Johannes Berg wrote:
> @@ -2615,27 +2588,104 @@ ieee80211_rx_mgmt(struct net_device *dev
>                  fi->ssi_noise = 0x00000000;
>                  fi->encoding = 0;
>  	} else {
> +		/* clear everything because we really don't know.
> +		 * the msg_type field isn't present on monitor frames
> +		 * so we don't know whether it will be present or not,
> +		 * but it's ok to not clear it since it'll be assigned
> +		 * anyway */
> +		memset(fi, 0, sizeof(*fi) - sizeof(fi->msg_type));

offsetof(ieee80211_frame_info, msg_type)? But it doesn't matter, this
is going to go away (hopefully soon) anyway.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
