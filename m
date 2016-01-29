From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: WARNING at net/mac80211/rate.c:513 ieee80211_get_tx_rates [mac80211]
Date: Thu, 28 Jan 2016 20:19:49 -0800
Message-ID: <CA+55aFz79CwRsQJjN9LSKr68c0JQR8DrK16C6_8SwXct3pbnhg@mail.gmail.com>
References: <CA+55aFxe22iWok6UojY=hCoG2k1wNpJ9CfQ0b+STSxq67tb86Q@mail.gmail.com>
	<1453983185.2217.12.camel@sipsolutions.net>
	<CA+55aFya9K4JboNY8kB9cg6zt9otguhdzfHm3jvLmWedxQTSWg@mail.gmail.com>
	<1454013625.2332.9.camel@sipsolutions.net>
	<CA+55aFx73nv9ny-fu5BR6v8wL=f2oFomwrZoLRw=x2kNP76cYA@mail.gmail.com>
	<CA+55aFzF0gWfvmE+6ZcHmjnO4xp-oVAQ5SWxYJhOzns2ocgCsw@mail.gmail.com>
	<1454019155.2332.15.camel@sipsolutions.net>
	<CA+55aFxjpdepHYD_6uU48kW38Z9bmf2wwA8yPZt4ibhkofmfQA@mail.gmail.com>
	<56AAC66C.1080800@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56AAC66C.1080800-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 28, 2016 at 5:54 PM, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> wrote:
>
> I have been running an RTL8821AE since kernel 3.18 without hitting this
> problem using a TRENDnet AC1750 dual-band AP. The UniFi may be doing
> something that the driver is not expecting.

I've had issues with unifi ap's before, but to be honest, I've had
issues with lots of hotel and airport wifi too. I don't think the
Unifi APs are outside of the normal spectrum..

> Attached is a minimal patch that comments out the "vht_cap->vht_supported =
> true;" statement for both RTL8821AE and RTL8812AE in
> _rtl_init_hw_vht_capab(). Does that allow your system to work?

That works too, yes.

> The patch
> also logs some information regarding the channelplan and the country code.
> Please let me know the values for those.

  rtlwifi: **** channelplan 127
  rtlwifi: **** country code 13

> I apparently missed a previous complaint about this issue. If you still have
> the reference, please send it to me.

So googling for similar issues, I found

  https://bugzilla.redhat.com/show_bug.cgi?id=1168467
  https://bugzilla.redhat.com/show_bug.cgi?id=1293136

where that second one in particular looks very like my issue
("Association succeeds, and ARP/DHCP work, but no IP frames can be
transmitted").

In both cases you have to go into the dmesg attachment to see that its
rtlwifi in both cases).

And there's an ubuntuforum thread

  http://ubuntuforums.org/showthread.php?t=2226009&page=2

where it you follow the thing, it's an rtl chip on a PCI card, and it
has very similar "connected but no internet" behavior, along with the
"net/mac80211/rate.c:526" warning (different line numbers, different
kernel version, but it smells similar).

Or this one:

  http://forums.debian.net/viewtopic.php?f=5&t=111781

which is also rtl-wifi, and also has the "associated, connected, got
an IP, but no data, not even a ping" behavior. It also has the
warning, but it looks different in other ways (2.4GHz only and
actually says it's not doing HT/VHT).

So I don't know. The warning in net/mac80211/rate.c:does seem to be
associated with the realtek driver.

             Linus
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
