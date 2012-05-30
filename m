From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 1/4] mac80211: Fix likely misuse of | for &
Date: Wed, 30 May 2012 13:29:42 -0700
Message-ID: <4FC68336.3000806@candelatech.com>
References: <cover.1338408931.git.joe@perches.com> <aa9c55edda55d38111660c0b250d12d79f6e1755.1338408931.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <aa9c55edda55d38111660c0b250d12d79f6e1755.1338408931.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/30/2012 01:25 PM, Joe Perches wrote:
> Using | with a constant is always true.
> Likely this should have be&.

Yes, I think your change is correct.  Looks like something
a compiler or static analysis tool could catch and warn about...

Sorry for the bug!

Ben

>
> cc: Ben Greear<greearb@candelatech.com>
> Signed-off-by: Joe Perches<joe@perches.com>
> ---
>   net/mac80211/cfg.c |    6 +++---
>   1 files changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
> index 495831e..e9cecca 100644
> --- a/net/mac80211/cfg.c
> +++ b/net/mac80211/cfg.c
> @@ -533,16 +533,16 @@ static void ieee80211_get_et_stats(struct wiphy *wiphy,
>   		sinfo.filled = 0;
>   		sta_set_sinfo(sta,&sinfo);
>
> -		if (sinfo.filled | STATION_INFO_TX_BITRATE)
> +		if (sinfo.filled&  STATION_INFO_TX_BITRATE)
>   			data[i] = 100000 *
>   				cfg80211_calculate_bitrate(&sinfo.txrate);
>   		i++;
> -		if (sinfo.filled | STATION_INFO_RX_BITRATE)
> +		if (sinfo.filled&  STATION_INFO_RX_BITRATE)
>   			data[i] = 100000 *
>   				cfg80211_calculate_bitrate(&sinfo.rxrate);
>   		i++;
>
> -		if (sinfo.filled | STATION_INFO_SIGNAL_AVG)
> +		if (sinfo.filled&  STATION_INFO_SIGNAL_AVG)
>   			data[i] = (u8)sinfo.signal_avg;
>   		i++;
>   	} else {


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
