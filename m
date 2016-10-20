From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH 3/4] ptp_clock: allow for it to be optional
Date: Thu, 20 Oct 2016 13:47:29 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1610201338330.25105@knanqh.ubzr>
References: <1476920573-14384-1-git-send-email-nicolas.pitre@linaro.org> <1476920573-14384-4-git-send-email-nicolas.pitre@linaro.org> <alpine.DEB.2.20.1610201149190.5073@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: John Stultz <john.stultz@linaro.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Yann E MORIN <yann.morin.1998@free.fr>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.20.1610201149190.5073@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 20 Oct 2016, Thomas Gleixner wrote:

> On Wed, 19 Oct 2016, Nicolas Pitre wrote:
> > The pch_gbe driver is a bit special as it relies on extra code in
> > drivers/ptp/ptp_pch.c. Therefore we let the make process descend into
> > drivers/ptp/ even if PTP_1588_CLOCK is unselected.
> 
> The above paragraph looks like a leftover of the previous patch set.

Not really.  Without the change to drivers/Makefile, drivers/ptp/ is not 
visited when CONFIG_PTP_1588_CLOCK=n. If you then have CONFIG_PCH_GBE=y 
you end up with:

drivers/built-in.o: In function `pch_gbe_ioctl':
pch_gbe_main.c:(.text+0x28c914): undefined reference to `pch_ch_control_write'
pch_gbe_main.c:(.text+0x28c945): undefined reference to `pch_set_station_address'
pch_gbe_main.c:(.text+0x28c964): undefined reference to `pch_ch_event_write'
pch_gbe_main.c:(.text+0x28c9ae): undefined reference to `pch_ch_control_write'
pch_gbe_main.c:(.text+0x28c9c7): undefined reference to `pch_ch_control_write'
pch_gbe_main.c:(.text+0x28c9e6): undefined reference to `pch_ch_control_write'
pch_gbe_main.c:(.text+0x28ca17): undefined reference to `pch_set_station_address'
drivers/built-in.o: In function `pch_gbe_xmit_frame':
pch_gbe_main.c:(.text+0x28ceab): undefined reference to `pch_ch_event_read'
pch_gbe_main.c:(.text+0x28cebb): undefined reference to `pch_tx_snap_read'
pch_gbe_main.c:(.text+0x28ced8): undefined reference to `pch_ch_event_write'
drivers/built-in.o: In function `pch_gbe_napi_poll':
pch_gbe_main.c:(.text+0x28da6c): undefined reference to `pch_ch_event_read'
pch_gbe_main.c:(.text+0x28da78): undefined reference to `pch_src_uuid_lo_read'
pch_gbe_main.c:(.text+0x28da83): undefined reference to `pch_src_uuid_hi_read'
pch_gbe_main.c:(.text+0x28db0c): undefined reference to `pch_ch_event_write'
pch_gbe_main.c:(.text+0x28df69): undefined reference to `pch_rx_snap_read'
pch_gbe_main.c:(.text+0x28df88): undefined reference to `pch_ch_event_write'
make: *** [vmlinux] Error 1

Hence the above paragraph.


Nicolas
