From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/5] net: rfkill: add rfkill_find_type function
Date: Thu, 13 Aug 2015 11:27:46 +0200
Message-ID: <1439458066.2114.13.camel@sipsolutions.net>
References: <1438781947-7952-1-git-send-email-heikki.krogerus@linux.intel.com>
	 <1438781947-7952-3-git-send-email-heikki.krogerus@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org
To: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438781947-7952-3-git-send-email-heikki.krogerus@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-08-05 at 16:39 +0300, Heikki Krogerus wrote:
> 
> +static const char *rfkill_types[NUM_RFKILL_TYPES] = {
> +	[RFKILL_TYPE_WLAN]	= "wlan",
> +	[RFKILL_TYPE_BLUETOOTH]	= "bluetooth",
> +	[RFKILL_TYPE_UWB]	= "ultrawideband",
> +	[RFKILL_TYPE_WIMAX]	= "wimax",
> +	[RFKILL_TYPE_WWAN]	= "wwan",
> +	[RFKILL_TYPE_GPS]	= "gps",
> +	[RFKILL_TYPE_FM]	= "fm",
> +	[RFKILL_TYPE_NFC]	= "nfc",
> +};
> +
> +enum rfkill_type rfkill_find_type(const char *name)
> +{
> +	int i;
> +
> +	BUILD_BUG_ON(NUM_RFKILL_TYPES != RFKILL_TYPE_NFC + 1);
> 
That BUILD_BUG_ON() is now less useful - previously it pointed to the
code that needed to change, now you're left wondering if you don't look
up since it isn't quite that obvious from the code what this does.

Something like

	BUILD_BUG_ON(rfkill_types[NUM_RFKILL_TYPES - 1] == NULL);

would be better. As we only add here, that would be safe enough - I've
done something similar in the past that a bit more complicated.

With that and the static inline fixed (which maybe you could even
remove) I'm fine with all these rfkill patches, but I'm not sure how to
merge them since they affect all kinds of other trees. If desired, I
can apply them, but an ACK from the tegra maintainer would be good :)

johannes
