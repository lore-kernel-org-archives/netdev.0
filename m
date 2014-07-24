From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211_hwsim: fix compiler warning on MIPS
Date: Thu, 24 Jul 2014 12:54:31 +0200
Message-ID: <1406199271.14675.10.camel@jlt4.sipsolutions.net>
References: <1406065431-20813-1-git-send-email-abrestic@chromium.org>
	 (sfid-20140722_234503_746857_0630E11C)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrew Bresticker <abrestic@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406065431-20813-1-git-send-email-abrestic@chromium.org> (sfid-20140722_234503_746857_0630E11C)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-07-22 at 14:43 -0700, Andrew Bresticker wrote:
> The dividend in do_div() is expected to be an unsigned 64-bit integer,
> which leads to the following warning when building for 32-bit MIPS:
> 
>   drivers/net/wireless/mac80211_hwsim.c: In function 'mac80211_hwsim_set_tsf':
>   drivers/net/wireless/mac80211_hwsim.c:664:98: warning: comparison of distinct pointer types lacks a cast [enabled by default]
>     data->bcn_delta = do_div(delta, bcn_int);
> 
> Since we care about the signedness of delta when adjusting tsf_offset
> and bcm_delta, use the absolute value for the division and compare
> the two timestamps to determine the sign.

Applied, thanks.

johannes
