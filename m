From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 7/7] d80211: getting wrong freq value if we did hardware
 scan
Date: Thu, 21 Sep 2006 19:29:34 +0200
Message-ID: <20060921192934.5260dfdc@logostar.upir.cz>
References: <44F358B8.60700@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:4779 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751371AbWIUR3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 13:29:41 -0400
To: mabbas <mabbas@linux.intel.com>
In-Reply-To: <44F358B8.60700@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 28 Aug 2006 13:57:28 -0700, mabbas wrote:
> diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
> index a933d92..374193e 100644
> --- a/net/d80211/ieee80211_sta.c
> +++ b/net/d80211/ieee80211_sta.c
> @@ -1543,8 +1543,6 @@ #endif
>  	bss->channel = channel;
>  	bss->freq = local->conf.freq;
>  	if (channel != local->conf.channel &&
> -	    (local->conf.phymode == MODE_IEEE80211G ||
> -	     local->conf.phymode == MODE_IEEE80211B) &&
>  	    channel >= 1 && channel <= 14) {

The patch doesn't look correct. As I already wrote, no hackish guessing of
the phymode from channel numbers, please.

Are there any problems with just using rx_status->phymode instead of
local->conf.phymode (other than "drivers don't set that field" as that can
be easily fixed)?

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
