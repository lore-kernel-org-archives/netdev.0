From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: mac80211: tx.c: be sure of 'sdata->vif.type' must
 be NL80211_IFTYPE_AP when be in NL80211_IFTYPE_AP case
Date: Fri, 29 Nov 2013 16:38:07 +0100
Message-ID: <1385739487.8656.1.camel@jlt4.sipsolutions.net>
References: <528AEFB7.4060301@gmail.com>
	 <20131125011938.GB18921@codeaurora.org> <5292B845.3010404@gmail.com>
	 <5292B8A0.7020409@gmail.com> <5294255E.7040105@gmail.com>
	 <52957ADA.2080704@gmail.com> (sfid-20131127_055211_558798_A7DF5684)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	rkuo <rkuo@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen.5i5j@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52957ADA.2080704@gmail.com> (sfid-20131127_055211_558798_A7DF5684)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> +++ b/net/mac80211/tx.c
> @@ -1814,8 +1814,9 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
>  			break;
>  		/* fall through */
>  	case NL80211_IFTYPE_AP:
> -		if (sdata->vif.type == NL80211_IFTYPE_AP)
> -			chanctx_conf = rcu_dereference(sdata->vif.chanctx_conf);
> +		if (sdata->vif.type != NL80211_IFTYPE_AP)
> +			goto fail_rcu;
> +		chanctx_conf = rcu_dereference(sdata->vif.chanctx_conf);

This change is completely wrong.

johannes
