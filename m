From: Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH v2] mac80211: fix GCC warning on 64bit platforms
Date: Wed, 18 Jul 2007 11:14:40 -0500
Message-ID: <469E3C70.4070809@lwfinger.net>
References: <20070714.185935.18577806.davem@davemloft.net>	<20070714.204116.23012949.davem@davemloft.net>	<20070716184653.355253bf@griffin.suse.cz>	<20070716.145358.35015496.davem@davemloft.net> <20070718171044.2de287cd@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070718171044.2de287cd-IhiK2ZEFs2oCVLCxKZUutA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jiri Benc wrote:
> net/mac80211/ieee80211.c: In function ieee80211_register_hw:
> net/mac80211/ieee80211.c:4989: warning: comparison of distinct pointer types lacks a cast
> 
> Size of ieee80211_tx_status_rtap_hdr structure will never be greater than
> unsigned int.
> 
> Signed-off-by: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
> 
> ---
> 
> On Mon, 16 Jul 2007 14:53:58 -0700 (PDT), David Miller wrote:
>> The macro "max_t" exists for these kinds of situations, please
>> use it. :-)
> 
> Ok.
> 
> ---
>  net/mac80211/ieee80211.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> --- mac80211-2.6.orig/net/mac80211/ieee80211.c
> +++ mac80211-2.6/net/mac80211/ieee80211.c
> @@ -4986,8 +4986,8 @@ int ieee80211_register_hw(struct ieee802
>  	 * and we need some headroom for passing the frame to monitor
>  	 * interfaces, but never both at the same time.
>  	 */
> -	local->tx_headroom = max(local->hw.extra_tx_headroom,
> -				 sizeof(struct ieee80211_tx_status_rtap_hdr));
> +	local->tx_headroom = max_t(unsigned, local->hw.extra_tx_headroom,
> +				   sizeof(struct ieee80211_tx_status_rtap_hdr));
>  
>  	debugfs_hw_add(local);

For my info on how to use max_t, not as a critique of this patch. (1) Is 'unsigned' enough or should 
it be 'unsigned int'? (2) Because tx_headroom is an int, why use unsigned at all?

Larry
