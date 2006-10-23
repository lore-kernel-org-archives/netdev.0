From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [patch 1/2]d80211: hardware TKIP support for ipw3945
Date: Mon, 23 Oct 2006 14:40:28 +0200
Message-ID: <20061023144028.629dc5d8@griffin.suse.cz>
References: <1161335976.21402.11.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:62428 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751938AbWJWMka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2006 08:40:30 -0400
To: Hong Liu <hong.liu@intel.com>
In-Reply-To: <1161335976.21402.11.camel@devlinux-hong>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 20 Oct 2006 17:19:36 +0800, Hong Liu wrote:
> --- a/include/net/d80211.h
> +++ b/include/net/d80211.h
> @@ -176,6 +176,7 @@ struct ieee80211_tx_control {
>  			*/
>  	int icv_len:8; /* Length of the ICV/MIC field in octets */
>  	int iv_len:8; /* Length of the IV field in octets */
> +	u8 rc4key[16]; /* generated RC4 key for hw TKIP */

I don't like extending ieee80211_tx_control by 16 more bytes. The
driver is required to store a copy of each ieee80211_tx_control
(because it's copied to ieee80211_tx_status). I don't have a better
idea, though. Anybody?

> @@ -476,6 +477,12 @@ struct ieee80211_hw {
>  	/* Force software encryption for TKIP packets if WMM is enabled. */
>  	unsigned int no_tkip_wmm_hwaccel:1;
>  
> +	/* Do TKIP key mixing in stack, send the generated RC4 key with
> +	 * with each TX frame */
> +	unsigned int tkip_include_rc4key:1;
> +	/* calculate michael MIC in stack */
> +	unsigned int tkip_include_mmic:1;

Please write more descriptive comments (e.g. there should be stated
that tkip_include_mmic is relevant only when using hw crypto).

Also, it would help if you don't use bitfileds and rebase your patch
on top of http://www.spinics.net/lists/netdev/msg17316.html and
http://www.spinics.net/lists/netdev/msg17314.html; but I can do it for
you when applying the patch.

> +void ieee80211_tkip_gen_rc4key(struct ieee80211_key *key,
> +			       u8 *rc4key, u8* ta)

Put the destination buffer (rc4key) as the last parameter.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
