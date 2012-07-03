From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: linux-next: manual merge of the net-next tree with the wireless
 tree
Date: Mon, 2 Jul 2012 22:33:25 -0400
Message-ID: <20120703023325.GA12530@tuxdriver.com>
References: <20120703114443.26e03246debd0652e8d1e92b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eliad Peller <eliad@wizery.com>,
	Johannes Berg <johannes.berg@intel.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120703114443.26e03246debd0652e8d1e92b@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 03, 2012 at 11:44:43AM +1000, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next merge of the net-next tree got a conflict in
> net/mac80211/mlme.c between commit 0030bc586591 ("mac80211: destroy
> assoc_data correctly if assoc fails") from the wireless tree and commit
> bdcbd8e0e3ff ("mac80211: clean up debugging") from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary.
> -- 
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
> 
> diff --cc net/mac80211/mlme.c
> index 0db5d34,e6fe84a..0000000
> --- a/net/mac80211/mlme.c
> +++ b/net/mac80211/mlme.c
> @@@ -2170,17 -2148,19 +2148,17 @@@ ieee80211_rx_mgmt_assoc_resp(struct iee
>   	*bss = assoc_data->bss;
>   
>   	if (status_code != WLAN_STATUS_SUCCESS) {
> - 		printk(KERN_DEBUG "%s: %pM denied association (code=%d)\n",
> - 		       sdata->name, mgmt->sa, status_code);
> + 		sdata_info(sdata, "%pM denied association (code=%d)\n",
> + 			   mgmt->sa, status_code);
>   		ieee80211_destroy_assoc_data(sdata, false);
>   	} else {
>  -		sdata_info(sdata, "associated\n");
>  -
>   		if (!ieee80211_assoc_success(sdata, *bss, mgmt, len)) {
>   			/* oops -- internal error -- send timeout for now */
>  -			ieee80211_destroy_assoc_data(sdata, true);
>  -			sta_info_destroy_addr(sdata, mgmt->bssid);
>  +			ieee80211_destroy_assoc_data(sdata, false);
>   			cfg80211_put_bss(*bss);
>   			return RX_MGMT_CFG80211_ASSOC_TIMEOUT;
>   		}
> - 		printk(KERN_DEBUG "%s: associated\n", sdata->name);
> ++		sdata_info(sdata, "associated\n");
>   
>   		/*
>   		 * destroy assoc_data afterwards, as otherwise an idle

Looks good to me.

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
