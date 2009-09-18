From: Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>
Subject: Re: [origin tree build failure] [PATCH] Fix: (.text+0x22ec88): undefined reference to `ieee80211_unregister_hw'
Date: Fri, 18 Sep 2009 11:09:39 -0700
Message-ID: <87tyz0gm58.fsf@nokia.com>
References: <20090911.202543.52533792.davem@davemloft.net>
	<20090915114958.GA26902@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>,
	"Coelho Luciano \(Nokia-D\/Helsinki\)" <Luciano.Coelho-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>,
	"Oikarinen Juuso \(Nokia-D\/Tampere\)" <juuso.oikarinen-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>,
	"torvalds\@linux-foundation.org" <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"akpm\@linux-foundation.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090915114958.GA26902-X9Un+BFzKDI@public.gmane.org> (ext Ingo Molnar's message of
	"Tue, 15 Sep 2009 13:49:58 +0200")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org> writes:

> FYI, -tip testing found that something in this lot broke the build with 
> certain configs (attached):
>
> drivers/built-in.o: In function `wl1251_free_hw':
> (.text+0x22ec88): undefined reference to `ieee80211_unregister_hw'
> drivers/built-in.o: In function `wl1251_free_hw':
> (.text+0x22ecf5): undefined reference to `ieee80211_free_hw'
> drivers/built-in.o: In function `wl1251_op_bss_info_changed':
> wl1251_main.c:(.text+0x22f161): undefined reference to `ieee80211_beacon_get'
> drivers/built-in.o: In function `wl1251_op_config':
> wl1251_main.c:(.text+0x22f2f8): undefined reference to `ieee80211_frequency_to_channel'
> drivers/built-in.o: In function `wl1251_op_stop':
> wl1251_main.c:(.text+0x22f554): undefined reference to `ieee80211_scan_completed'
> drivers/built-in.o: In function `wl1251_op_tx':
> wl1251_main.c:(.text+0x22f6a5): undefined reference to `ieee80211_queue_work'
> wl1251_main.c:(.text+0x22f6b6): undefined reference to `ieee80211_stop_queues'
> drivers/built-in.o: In function `wl1251_alloc_hw':
> (.text+0x22f710): undefined reference to `ieee80211_alloc_hw'
> drivers/built-in.o: In function `wl1251_alloc_hw':
> (.text+0x22f9e4): undefined reference to `ieee80211_free_hw'
> drivers/built-in.o: In function `wl1251_init_ieee80211':
> (.text+0x2305df): undefined reference to `ieee80211_register_hw'
> drivers/built-in.o: In function `wl1251_event_handle':
> (.text+0x2306c4): undefined reference to `ieee80211_scan_completed'
> drivers/built-in.o: In function `wl1251_tx_flush':
> (.text+0x230810): undefined reference to `ieee80211_tx_status'
> drivers/built-in.o: In function `wl1251_tx_flush':
> (.text+0x230846): undefined reference to `ieee80211_tx_status'
> drivers/built-in.o: In function `wl1251_tx_frame':
> wl1251_tx.c:(.text+0x230a97): undefined reference to `ieee80211_hdrlen'
> drivers/built-in.o: In function `wl1251_tx_complete':
> (.text+0x230d30): undefined reference to `ieee80211_get_hdrlen_from_skb'
> drivers/built-in.o: In function `wl1251_tx_complete':
> (.text+0x230d58): undefined reference to `ieee80211_tx_status'
> drivers/built-in.o: In function `wl1251_tx_complete':
> (.text+0x230dc0): undefined reference to `ieee80211_wake_queues'
> drivers/built-in.o: In function `wl1251_tx_work':
> (.text+0x230f57): undefined reference to `ieee80211_stop_queues'
> drivers/built-in.o: In function `wl1251_rx':
> (.text+0x231187): undefined reference to `ieee80211_channel_to_frequency'
> drivers/built-in.o: In function `wl1251_rx':
> (.text+0x2311e4): undefined reference to `ieee80211_rx'
>
> Turning CONFIG_WL1251 off makes it build.
>
> A (very) quick first look suggests that not all prior dependencies were 
> carried over to the new drivers in drivers/net/wireless/wl12xx/Kconfig:
>
> -config WL12XX
> -       tristate "TI wl1251/wl1271 support"
> -       depends on MAC80211 && WLAN_80211 && SPI_MASTER && 
> GENERIC_HARDIRQS && EXPERIMENTAL
> +menuconfig WL12XX
> +       boolean "TI wl12xx driver support"
> +       depends on MAC80211 && WLAN_80211 && EXPERIMENTAL
> +       ---help---
> +         This will enable TI wl12xx driver support. The drivers make
> +         use of the mac80211 stack.
> +
> +config WL1251
> +       tristate "TI wl1251 support"
> +       depends on WL12XX && GENERIC_HARDIRQS
>
> the friction is between modular/build-in mode:
>
>  CONFIG_WL1251=y
>  CONFIG_MAC80211=m
>
> Kconfig does not carry over the modular dependency from WL12XX to 
> WL1251. An explicit rule via the patch below turns CONFIG_WL1251 into a 
> modular entry as well:
>
>  CONFIG_WL12XX=y
>  CONFIG_WL1251=m
>
> ( Note: i have tested this patch with this particular config and it 
>   solves the problem there but have not investigated any deeper. )
>
> 	Ingo
>
> Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

I missed this state entirely, thanks for fixing this.

Acked-by: Kalle Valo <kalle.valo-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

"wl1251:" prefix is just missing from the commit summary.

Who is going to take the patch? Should I send this to John?

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
