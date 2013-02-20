From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: 3.7.8/amd64 full interrupt hangs due to iwlwifi under big nfs
 copies out
Date: Wed, 20 Feb 2013 20:58:10 +0100
Message-ID: <1361390290.8579.4.camel@jlt4.sipsolutions.net>
References: <1333998672.3007.245.camel@edumazet-glaptop>
	 <20120409.153452.1284163346306246866.davem@davemloft.net>
	 <1334030180.13293.98.camel@edumazet-glaptop>
	 <20120410051127.GA32048@merlins.org>
	 <1334038263.2907.1.camel@edumazet-glaptop>
	 <20120411052733.GA17352@merlins.org> <20120715215935.GF24420@merlins.org>
	 <1342419529.3265.12217.camel@edumazet-glaptop>
	 <20120716151826.GA10586@merlins.org>
	 <1342455717.2830.14.camel@edumazet-glaptop>
	 <20130219040557.GB4778@merlins.org>
	 <1361251033.19353.120.camel@edumazet-glaptop>
	 (sfid-20130219_061917_530878_1ED7A14C) <1361268221.8553.1.camel@jlt4.sipsolutions.net>
	 <1361290909.19353.140.camel@edumazet-glaptop>
	 (sfid-20130219_172155_748777_C3ED0F5E) <1361351538.8629.3.camel@jlt4.sipsolutions.net>
	 (sfid-20130220_101252_930264_DBD3955C) <1361351703.8629.5.camel@jlt4.sipsolutions.net>
	 <1361373064.19353.180.camel@edumazet-glaptop>
	 (sfid-20130220_161110_395796_DBAC0744) <1361377243.8629.34.camel@jlt4.sipsolutions.net>
	 <1361379331.19353.189.camel@edumazet-glaptop>
	 (sfid-20130220_175537_373410_F2F98F44) <1361379686.8629.41.camel@jlt4.sipsolutions.net>
	 <1361381096.19353.195.camel@edumazet-glaptop>
	 (sfid-20130220_182502_483935_369E6954) <1361384183.8579.1.camel@jlt4.sipsolutions.net>
	 <1361387854.19353.214.camel@edumazet-glaptop>
	 (sfid-20130220_201740_409859_E87FECD4)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marc MERLIN <marc-xnduUnryOU1AfugRpC6u6w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1361387854.19353.214.camel@edumazet-glaptop> (sfid-20130220_201740_409859_E87FECD4)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-02-20 at 11:17 -0800, Eric Dumazet wrote:
> On Wed, 2013-02-20 at 19:16 +0100, Johannes Berg wrote:
> 
> > Yes and no. The current code doesn't pull in much data, not even the IP
> > header, so worst case it copies 14 bytes (ethernet header) in mac80211
> > to obtain alignment. By pulling in everything here, it later has to copy
> > everything again later to obtain alignment.
> 
> Can you give me pointers to the code doing that ?

Sure: net/mac80211/rx.c ~line 1900, look for #ifndef
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS.

> On x86 we should not doing anything.

We don't do anything if CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is
defined.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
