From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH -next] mac80211: Use #define IEEE80211_CCMP_PN_LEN and
 bool
Date: Mon, 30 Mar 2015 22:01:58 +0200
Message-ID: <1427745718.26117.46.camel@sipsolutions.net>
References: <1427733474.14276.11.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427733474.14276.11.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-03-30 at 09:37 -0700, Joe Perches wrote:

> @@ -89,11 +90,11 @@ struct ieee80211_fragment_entry {
>  	unsigned int last_frag;
>  	unsigned int extra_len;
>  	struct sk_buff_head skb_list;
> -	int ccmp; /* Whether fragments were encrypted with CCMP */
> -	u8 last_pn[6]; /* PN of the last fragment if CCMP was used */
> +	/* for CCMP fragments */
> +	bool ccmp;				/* encrypted with CCMP */
> +	u8 last_pn[IEEE80211_CCMP_PN_LEN];	/* PN of the last fragment */

I took your patch as an opportunity to check into this, and it turns out
all of this logic is also going to be needed for GCMP. As a result, I'm
not going to take this patch but instead we'll fix it up for GCMP (where
using CCMP_PN_LEN would not be appropriate anyway - perhaps we need a
union or just keep '8' which is the right size for both anyway, or we'll
go to a u64 value or something)

johannes
