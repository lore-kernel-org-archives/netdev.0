From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: WARNING at net/mac80211/rate.c:513 ieee80211_get_tx_rates [mac80211]
Date: Thu, 28 Jan 2016 15:01:26 -0800
Message-ID: <CA+55aFxjpdepHYD_6uU48kW38Z9bmf2wwA8yPZt4ibhkofmfQA@mail.gmail.com>
References: <CA+55aFxe22iWok6UojY=hCoG2k1wNpJ9CfQ0b+STSxq67tb86Q@mail.gmail.com>
	<1453983185.2217.12.camel@sipsolutions.net>
	<CA+55aFya9K4JboNY8kB9cg6zt9otguhdzfHm3jvLmWedxQTSWg@mail.gmail.com>
	<1454013625.2332.9.camel@sipsolutions.net>
	<CA+55aFx73nv9ny-fu5BR6v8wL=f2oFomwrZoLRw=x2kNP76cYA@mail.gmail.com>
	<CA+55aFzF0gWfvmE+6ZcHmjnO4xp-oVAQ5SWxYJhOzns2ocgCsw@mail.gmail.com>
	<1454019155.2332.15.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>,
	David Miller <davem@davemloft.net>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34593 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbcA1XB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 18:01:27 -0500
In-Reply-To: <1454019155.2332.15.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 28, 2016 at 2:12 PM, Johannes Berg
<johannes@sipsolutions.net> wrote:
>
> Your best workaround may just be to ignore VHT for now - clearly it's
> broken so using "just" HT (which is likely not that much of a penalty
> anyway since you're apparently not using 80 MHz) will be much better.
>
> Go into
>
> _rtl_init_hw_vht_capab()
>
> and just remove or stub out the entire contents of that (or you could
> just remove the "vht_supported=true" if you feel like it.)
>
> That should get it to HT only, which is likely tested and working
> better.

Bingo. That indeed gets me working wireless. It's not super-fast, but
I don't think it ever has been..

If somebody has a suggested patch to actually *fix* VHT on this
chipset, that would obviously be better. And maybe it works on some
other chipsets, but not on mine. I'll happily test patches now that
the merge window is over and I have some time again (and I can also
make my AP do 80MHz channels if that matters, although as Johannes
noted it's not enabled by default).

For the realtek driver people, here is what lspci says:

02:00.0 Network controller: Realtek Semiconductor Co., Ltd. RTL8821AE
802.11ac PCIe Wireless Network Adapter
    Subsystem: AzureWave Device 2161
    Kernel driver in use: rtl8821ae

(Numeric PCI ID: 10ec:8821, subsystem 1a3b:2161)

Thanks,

              Linus
