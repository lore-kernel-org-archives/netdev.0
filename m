From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/2] mac80211: fix compilation warning
Date: Tue, 14 Sep 2010 07:17:12 +0200
Message-ID: <1284441432.3704.0.camel@jlt3.sipsolutions.net>
References: <1284289829-25425-1-git-send-email-felipe.contreras@gmail.com>
	 <1284289829-25425-3-git-send-email-felipe.contreras@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jiri Kosina <jkosina@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Kalle Valo <kalle.valo@iki.fi>,
	Felix Fietkau <nbd@openwrt.org>, Jouni Malinen <j@w1.fi>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Felipe Contreras <felipe.contreras@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1284289829-25425-3-git-send-email-felipe.contreras@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2010-09-12 at 14:10 +0300, Felipe Contreras wrote:

>  	struct ieee80211_hdr hdr;
> -	struct ieee80211s_hdr mesh_hdr;
>  	const u8 *encaps_data;
>  	int encaps_len, skip_header_bytes;
>  	int nh_pos, h_pos;
> @@ -1755,7 +1754,9 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
>  		hdrlen = 30;
>  		break;
>  #ifdef CONFIG_MAC80211_MESH
> -	case NL80211_IFTYPE_MESH_POINT:
> +	case NL80211_IFTYPE_MESH_POINT: {
> +		struct ieee80211s_hdr mesh_hdr;
> +

...

might be nicer to just add __maybe_unused.

johannes
