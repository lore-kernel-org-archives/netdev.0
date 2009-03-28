From: Marcin Slusarz <marcin.slusarz@gmail.com>
Subject: Re: Dereferencing freed memory bugs
Date: Sat, 28 Mar 2009 20:12:08 +0100
Message-ID: <49CE7688.2020501@gmail.com>
References: <a63d67fe0903240529v6a0e6b51pf67f8ad6dd6842c4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, eteo@redhat.com,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-media@vger.kernel.org, general@lists.openfabrics.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <a63d67fe0903240529v6a0e6b51pf67f8ad6dd6842c4@mail.gmail.com>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Carpenter wrote:
> I added a check to smatch (http://repo.or.cz/w/smatch.git/) to check
> for when we dereference
> freed memory.
> 
> drivers/dma/dmatest.c +410 dmatest_exit(7) 'dtc'
> drivers/dma/dmatest.c +412 dmatest_exit(9) 'dtc'

Seems to be fixed by 7cbd4877e5b167b56a3d6033b926a9f925186e12:
dmatest: fix use after free in dmatest_exit

> drivers/infiniband/hw/nes/nes_cm.c +563 nes_cm_timer_tick(121) 'cm_node'
> drivers/infiniband/hw/nes/nes_cm.c +621 nes_cm_timer_tick(179) 'cm_node'
> (...)
> drivers/usb/host/ehci-hcd.c +1661 itd_complete(79) 'stream'
> drivers/usb/host/ehci-hcd.c +2036 sitd_complete(64) 'stream'
> drivers/uwb/reset.c +193 __uwb_rc_cmd(26) 'cmd'
> (...)
> net/netfilter/xt_recent.c +273 recent_mt(69) 'e'
> (...)
> drivers/media/video/cpia_pp.c +777 cpia_pp_detach(28) 'cpia'
> (...)

These are less obvious.

Adding CCs.
Please leave only one of openfabrics/linux-usb/netdev/linux-media in CCs
when responding.

ps: [s]itd_complete is in drivers/usb/host/ehci-sched.c
