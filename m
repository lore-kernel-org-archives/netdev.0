From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 3/3] net: phy: leds: Fix truncated LED trigger names
Date: Wed, 25 Jan 2017 13:51:02 +0100
Message-ID: <20170125125102.GB2504@lunn.ch>
References: <1485340790-10785-1-git-send-email-geert+renesas@glider.be>
 <1485340790-10785-4-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Zach Brown <zach.brown@ni.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        Magnus =?iso-8859-1?Q?=D6berg?= <magnus.oberg@westermo.se>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1485340790-10785-4-git-send-email-geert+renesas@glider.be>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 25, 2017 at 11:39:50AM +0100, Geert Uytterhoeven wrote:
> Commit 4567d686f5c6d955 ("phy: increase size of MII_BUS_ID_SIZE and
> bus_id") increased the size of MII bus IDs, but forgot to update the
> private definition in <linux/phy_led_triggers.h>.
> This may cause:
>   1. Truncation of LED trigger names,
>   2. Duplicate LED trigger names,
>   3. Failures registering LED triggers,
>   4. Crashes due to bad error handling in the LED trigger failure path.
> 
> To fix this, and prevent the definitions going out of sync again in the
> future, let the PHY LED trigger code use the existing MII_BUS_ID_SIZE
> definition.
> 
> Example:
>   - Before I had triggers "ee700000.etherne:01:100Mbps" and
>     "ee700000.etherne:01:10Mbps",
>   - After the increase of MII_BUS_ID_SIZE, both became
>     "ee700000.ethernet-ffffffff:01:" => FAIL,
>   - Now, the triggers are "ee700000.ethernet-ffffffff:01:100Mbps" and
>     "ee700000.ethernet-ffffffff:01:10Mbps", which are unique again.
> 
> Fixes: 4567d686f5c6d955 ("phy: increase size of MII_BUS_ID_SIZE and bus_id")
> Fixes: 2e0bc452f4721520 ("net: phy: leds: add support for led triggers on phy link state change")
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
