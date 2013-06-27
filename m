From: Richard Genoud <richard.genoud@gmail.com>
Subject: Re: RTL8192CU on ARM not working
Date: Thu, 27 Jun 2013 14:13:31 +0200
Message-ID: <CACQ1gAiHVxjnt2qx5Y9dEMAbZs5Ki_wEHLhOjDRcPc+xjBU76A@mail.gmail.com>
References: <20130627081225.GJ5803@lukather>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Brian Lilly <brian@crystalfontz.com>,
	Brent-Crosby <brent@crystalfontz.com>, Jim Wall <jimwall@q.com>,
	Thomas Petazzoni <thomas@free-electrons.com>
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130627081225.GJ5803@lukather>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/6/27 Maxime Ripard <maxime.ripard@free-electrons.com>:
> Hi everyone,
>
> I'm currently trying to use a RTL8192CU on an ARM (Freescale imx28,
> armv5) platform, using 3.10-rc3.
>
> Trouble is, while the chip is correctly detected and you can use iw on it
> without any problem it seems, once you start an association to an access
> point, the association goes on, seems to associate, displaying a WARN()
> message [1] and then, after what looks like a random amount of time (could
> be right away, could be after a few minutes), deassociate [2].
>
> During the time where it's associated, we never seem to transmit any
> packets, while iw reports packets being sent, I guess we can assume that
> they are actually never transmitted as well [3].
>
> What seems odd to me as well is that the signal power reported for the access
> point is excessively high when using iw scan (10 dbm), and once connected, the
> signal strength is -64dbm, which makes quite a huge difference.
>
> Do you have any suggestions on how to solve this issue?
>
> Thanks,
> Maxime
>
>
> [1]:
> # iw wlan0 connect FreeWifi 2447
> # [  485.010858] wlan0: authenticate with f4:ca:e5:c9:f5:91
> [  485.065514] wlan0: send auth to f4:ca:e5:c9:f5:91 (try 1/3)
> [  485.075963] wlan0: authenticated
> [  485.088915] wlan0: associate with f4:ca:e5:c9:f5:91 (try 1/3)
> [  485.117137] wlan0: RX AssocResp from f4:ca:e5:c9:f5:91 (capab=0x401 status=0 aid=1)
> [  485.130607] wlan0: associated
> [  486.917555] ------------[ cut here ]------------
> [  486.922277] WARNING: at kernel/workqueue.c:1365 __queue_work+0x1f0/0x2f4()
> [  486.929175] Modules linked in:
> [  486.932284] CPU: 0 PID: 615 Comm: kworker/0:2 Not tainted 3.10.0-rc3 #2
> [  486.938958] Workqueue: rtl92c_usb rtl_watchdog_wq_callback
> [  486.944548] [<c00147dc>] (unwind_backtrace+0x0/0xf0) from [<c00120a0>] (show_stack+0x10/0x14)
> [  486.953132] [<c00120a0>] (show_stack+0x10/0x14) from [<c001d2ec>] (warn_slowpath_common+0x4c/0x68)
> [  486.962140] [<c001d2ec>] (warn_slowpath_common+0x4c/0x68) from [<c001d324>] (warn_slowpath_null+0x1c/0x24)
> [  486.971844] [<c001d324>] (warn_slowpath_null+0x1c/0x24) from [<c003769c>] (__queue_work+0x1f0/0x2f4)
> [  486.981025] [<c003769c>] (__queue_work+0x1f0/0x2f4) from [<c0037830>] (queue_work_on+0x80/0x88)
> [  486.989777] [<c0037830>] (queue_work_on+0x80/0x88) from [<c0267ca4>] (rtl_watchdog_wq_callback+0x5dc/0x8bc)
> [  486.999572] [<c0267ca4>] (rtl_watchdog_wq_callback+0x5dc/0x8bc) from [<c0038cbc>] (process_one_work+0x1c0/0x4c8)
> [  487.009795] [<c0038cbc>] (process_one_work+0x1c0/0x4c8) from [<c0039684>] (worker_thread+0x140/0x3ac)
> [  487.019065] [<c0039684>] (worker_thread+0x140/0x3ac) from [<c003f914>] (kthread+0xa4/0xb0)
> [  487.027381] [<c003f914>] (kthread+0xa4/0xb0) from [<c000f0c0>] (ret_from_fork+0x14/0x34)
> [  487.035498] ---[ end trace 93341a0c249e647e ]---
>
>
> [2]:
>
> # [  786.086127] wlan0: deauthenticated from f4:ca:e5:c9:f5:91 (Reason: 2)
> [  786.126368] cfg80211: Calling CRDA to update world regulatory domain
>
>
> [3]:
> # iw wlan0 station dump
> Station f4:ca:e5:c9:f5:91 (on wlan0)
>         inactive time:  55430 ms
>         rx bytes:       77826
>         rx packets:     1026
>         tx packets:     2
>         tx retries:     0
>         tx failed:      0
>         signal:         -64 dBm
>         signal avg:     -63 dBm
>         tx bitrate:     1.0 MBit/s
>         authorized:     yes
>         authenticated:  yes
>         preamble:       long
>         WMM/WME:        yes
>         MFP:            no
>         TDLS peer:      no

Hi Maxime,

You should have a look at https://lkml.org/lkml/2013/6/11/300
(in short, use 3.10-rc7)

The warning is still there, but I managed use this device on ARM
(sam9g35) as a client.

Regards,
Richard
