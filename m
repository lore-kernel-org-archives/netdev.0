From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: WARNING at net/mac80211/rate.c:513 ieee80211_get_tx_rates [mac80211]
Date: Fri, 29 Jan 2016 12:04:03 -0800
Message-ID: <CA+55aFz2QbPdFP1u5OWQgs=VkD1N1VcE7RUoeAoA9UAkvpVT4Q@mail.gmail.com>
References: <CA+55aFxe22iWok6UojY=hCoG2k1wNpJ9CfQ0b+STSxq67tb86Q@mail.gmail.com>
	<1453983185.2217.12.camel@sipsolutions.net>
	<CA+55aFya9K4JboNY8kB9cg6zt9otguhdzfHm3jvLmWedxQTSWg@mail.gmail.com>
	<1454013625.2332.9.camel@sipsolutions.net>
	<CA+55aFx73nv9ny-fu5BR6v8wL=f2oFomwrZoLRw=x2kNP76cYA@mail.gmail.com>
	<CA+55aFzF0gWfvmE+6ZcHmjnO4xp-oVAQ5SWxYJhOzns2ocgCsw@mail.gmail.com>
	<1454019155.2332.15.camel@sipsolutions.net>
	<CA+55aFxjpdepHYD_6uU48kW38Z9bmf2wwA8yPZt4ibhkofmfQA@mail.gmail.com>
	<56AAC66C.1080800@lwfinger.net>
	<1454056380.3369.2.camel@sipsolutions.net>
	<CAP71bdVZzUUNwP3py_m1pwU21qMKth=0BmMfLuUb7=B-1840zg@mail.gmail.com>
	<1454084146.2800.0.camel@sipsolutions.net>
	<56ABA73C.1060504@lwfinger.net>
	<CA+55aFysqqp-BCZs1ue6_1tE=h9SOUZTH_o7TwGbsaBnaFvXGA@mail.gmail.com>
	<56ABC0BC.9010202@lwfinger.net>
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
In-Reply-To: <56ABC0BC.9010202-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 29, 2016 at 11:42 AM, Larry Finger
<Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> wrote:
>
> Thanks for testing.
>
> Upon reflection, it really should check the other WIRELESS_MODE_AC_x bits.
> Johannes' patch was indeed correct.

I just retested with this incremental (and whitespace-damaged) patch:

  @@ -139,7 +139,9 @@ static void _rtl_rc_rate_set_series(struct
rtl_priv *rtlpriv,
                       (wireless_mode == WIRELESS_MODE_N_24G)))
                          rate->flags |= IEEE80211_TX_RC_MCS;
                  if (sta && sta->vht_cap.vht_supported &&
  -                   (wireless_mode == WIRELESS_MODE_AC_5G))
  +                   ((wireless_mode == WIRELESS_MODE_AC_5G) ||
  +                    (wireless_mode == WIRELESS_MODE_AC_24G) ||
  +                    (wireless_mode == WIRELESS_MODE_AC_ONLY)))
                          rate->flags |= IEEE80211_TX_RC_VHT_MCS;
          }
   }

which brings it in line with Johannes' patch, and it does indeed still work.

I think marking it for stable is also the right thing to do - the
driver clearly doesn't work well in a wide-channel AC environment
otherwise, and I assume it's going to be more and more common..

                Linus
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
