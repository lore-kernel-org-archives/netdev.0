From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] cfg80211: Be able to set bss expire time at config
 stage.
Date: Mon, 22 May 2017 18:19:14 +0200
Message-ID: <1495469954.26008.1.camel@sipsolutions.net>
References: <20170522160946.2057-1-enric.balletbo@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Dmitry Shmidt <dimitrysh@google.com>,
        helmut.schaa@googlemail.com
To: Enric Balletbo i Serra <enric.balletbo@collabora.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170522160946.2057-1-enric.balletbo@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-05-22 at 18:09 +0200, Enric Balletbo i Serra wrote:
> The IEEE80211_SCAN_RESULT_EXPIRE value was modified several times in
> the
> past. Initially was set at 10 seconds (2a51931192), then increased at
> 15
> seconds (09f97e0fc4) and finally to 30 seconds (f9616e0f88) to cover
> the
> use case when a station is having heavy uplink traffic. On some
> devices,
> like Chromebooks, this value is decreased to 7 seconds to avoid stall
> results, and other devices prefer set to 15 seconds.
> 
> This simple patch tries to make the selection of this value a bit
> more
> flexible by being able to set the expire time at config stage. Most
> users
> can leave the default value set as 30 seconds, others can modify the
> value
> at config stage if they want lower or bigger values.

I'm not really all that convinced that we really need this - userspace
should just be using the flush thing more often, and then it doesn't
really matter.

However, maybe that doesn't really matter all that much.

But,

> +config CFG80211_SCAN_RESULT_EXPIRE
> +	int "Scan completion time" if CFG80211

That should have "if CFG80211 && EXPERT" or something like that - no
need to prompt everyone for it.

> +	rdev->scan_result_expire =
> CONFIG_CFG80211_SCAN_RESULT_EXPIRE;

This is completely pointless - no need to go through runtime like that.

> -#define IEEE80211_SCAN_RESULT_EXPIRE	(30 * HZ)

You can just use CONFIG_CFG80211_SCAN_RESULT_EXPIRE * HZ here.

> +	__cfg80211_bss_expire(rdev, jiffies - rdev-
> >scan_result_expire);

You also completely messed this up because it now depends on HZ.

johannes
