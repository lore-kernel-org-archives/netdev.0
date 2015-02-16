From: "Nikita N." <nikitan-Z02xGKUfPWYS+FvcfC7Uqw@public.gmane.org>
Subject: brcmsmac: TX power blocked in BCM4313
Date: Mon, 16 Feb 2015 05:53:55 -0800
Message-ID: <1424094835.3188168.228077393.0E2006F5@webmail.messagingengine.com>
References: <1424007136.2042747.227726249.45B6A0E2@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org, brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Pat Erley <pat-lkml-Jx9fsTfDDR3YtjvyW6yDsg@public.gmane.org>, brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	Franky Lin <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	wens-jdAy2FN1RRM@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1424007136.2042747.227726249.45B6A0E2-2RFepEojUI2N1INw9kWLP6GC3tUn3ZHUQQ4Iyu8u01E@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dear brcmsmac Devs,
following up my previous email, since I didn't receive any feedback, I
took the trouble to test my understandings myself.
First of all, I want to report the following fact: the TX power is
blocked/fixed to 19dbm, no matter what local regdom or power setting.

If that is an issue or bug or else I leave the decision to you.
Another fact is that, the Windows driver for that same interface, is
capable to push the transceiver at least 10 RSSI points higher than
linux backports brcmsmac driver, which means it is *DO* possible to
change the TX power.
In my personal case I want to lower it, but even that is not possible:
no setting is working, neither changing the regdom (iw reg set) nor the
power (iwconfig wlan0 txpower, iw dev wlan0 set txpower fixed, iw phy
wlan0 set txpower fixed).

Now, as for my tests, I just tried to hard-code few values into the
brcmsmac driver module, only to see if anything changes.
In details I zeroed the values of all tx_power_offsets in the table
populated in wlc_lcnphy_txpower_recalc_target (phy_lcn.c), and called
wlc_lcnphy_set_target_tx_pwr with a value of 40 (minor that 52, which is
the minimum I found debugging that function).
Again, nothing changed (even if further calls to
wlc_lcnphy_set_target_tx_pwr =40)

It is my wish to create a patch for that "issue", which I want first to
test here locally to me, and if working&interesting, I can propose it
for merging in next release.
But, AMOF, now I'm just stuck.

In case anybody feels like giving away any hint/feedback, I would have
few questions:
1) is it "brcmsmac" linux backports driver still supported or
deprecated?
2) if deprecated, what is the supported driver for BCM4313?
3) About my tests, was it correct zeroing all tx_power_offsets in the
table and call wlc_lcnphy_set_target_tx_pwr=40, to get a TX power less
that 19dbm?
4) if it was not correct, or partially correct, what am I missing or
doing wrong, in order to push the TX transceiver power less than 19dbm?

Thanks for your attention.
-- 
  Nikita N.
  nikitan-Z02xGKUfPWYS+FvcfC7Uqw@public.gmane.org


On Sun, Feb 15, 2015, at 05:32 AM, Nikita N. wrote:
> Hi Dear backports Devs for driver brcmsmac,
> Coming to the point, I want to lower the TX power of my BCM4313, under
> the official values set by the regdom, to any special value I need.
> So I'm trying to build such a "personal" patch, only for me, based on
> latest backports v3.19 and latest Ubuntu.
> Useless to say, "iwconfig <wlan> txpower" doesn't work, the resulting TX
> power doesn't change.
> I know it doesn't work because I can measure the RSSI coming out from
> the BCM4313, using another device: it doesn't change, whatever value I
> set.
> 
> So, I gave a look at the code for the brcmsmac module, and I think I
> found the location where the TX power is *finally* set: inside
> wlc_lcnphy_txpower_recalc_target (phy_lcn.c), call to
> wlc_lcnphy_set_target_tx_pwr.
> AFAIU, in that function a table of tx_power_offsets (calculated by
> another function) is written in the device EPROM registry, and the TX
> power is set to the relative minimum.
> 
> Now, my question: is that the right way to change effectively the TX
> power?
> I need to ask You a confirmation about that, if that is correct, before
> I start building my patch.
> I don't want to frustrate my time developing in the wrong code, or
> damage the device, or other issues... :)
> 
> Thank you for your attention, and looking forward your feedback.
> 
> -- 
> http://www.fastmail.com - mmm... Fastmail...
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless"
> in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
http://www.fastmail.com - The professional email service

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
