From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: WARNING at net/mac80211/rate.c:513 ieee80211_get_tx_rates [mac80211]
Date: Thu, 28 Jan 2016 11:01:36 -0800
Message-ID: <CA+55aFya9K4JboNY8kB9cg6zt9otguhdzfHm3jvLmWedxQTSWg@mail.gmail.com>
References: <CA+55aFxe22iWok6UojY=hCoG2k1wNpJ9CfQ0b+STSxq67tb86Q@mail.gmail.com>
	<1453983185.2217.12.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1453983185.2217.12.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 28, 2016 at 4:13 AM, Johannes Berg
<johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> On Wed, 2016-01-27 at 21:34 -0800, Linus Torvalds wrote:
>
>> .. except now I upgraded the nearest access point, and now wireless
>> on that machine no longer works.
>
> Can you describe the upgrade a bit more, just for background?

I used to have the basic original UniFi UAP. I've replaced them with
the newer "AC Lite" version:

    https://www.ubnt.com/unifi/unifi-ap-ac-lite/

so it's a fairly big jump from a 2.4GHz-only network to a dual-band one.

The old 2.4GHz-only AP's showed the problem with minstrel-ht
incorrectly starting off at the highest rate (on a totally different
machine). So the Unifi AP's have shown problems in the kernel wireless
before, but so far it's always been the fault of the kernel wireless,
not the AP.

> Could you print out the entire table there when the warning happens?

This is the best I can come up with: printing out the index, and the
rate and bitrate tables:

  rates[i].idx (9) >= sband->n_bitrates (8)
  Rates:
      0: idx 9 count 1 flags a0
      1: idx 8 count 1 flags a0
      2: idx 7 count 2 flags a0
      3: idx 6 count 3 flags a0
  Bitrates:
      0: flags 00000002 bitrate 60 (hw: 0004 0000)
      1: flags 00000000 bitrate 90 (hw: 0005 0000)
      2: flags 00000002 bitrate 120 (hw: 0006 0000)
      3: flags 00000000 bitrate 180 (hw: 0007 0000)
      4: flags 00000002 bitrate 240 (hw: 0008 0000)
      5: flags 00000000 bitrate 360 (hw: 0009 0000)
      6: flags 00000000 bitrate 480 (hw: 000a 0000)
      7: flags 00000000 bitrate 540 (hw: 000b 0000)

So it's the very first rate that has index 9, but the bitrate table
only goes from 0-7.

So I suspect that once the first index has been marked invalid, it now
will never even look at the later indices, so it has no transmit rates
at all.  Or something.

That bitrate table does seem to match:

   static struct ieee80211_rate rtl_ratetable_5g[] = {

in drivers/net/wireless/realtek/rtlwifi/base.c

Does this give you any ideas?

              Linus
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
