From: "Dave Young" <hidave.darkstar@gmail.com>
Subject: Re: 2.6.24-rc8-mm1 : net tcp_input.c warnings
Date: Tue, 22 Jan 2008 12:37:29 +0800
Message-ID: <a8e1da0801212037uaa34a10xc2239ac7309a4ed0@mail.gmail.com>
References: <20080121075548.GA22177@darkstar.te-china.tietoenator.com>
	 <Pine.LNX.4.64.0801212302170.29700@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>
To: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:58790 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753728AbYAVEha convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 23:37:30 -0500
Received: by wx-out-0506.google.com with SMTP id h31so1236878wxd.4
        for <netdev@vger.kernel.org>; Mon, 21 Jan 2008 20:37:29 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.0801212302170.29700@kivilampi-30.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 22, 2008 5:14 AM, Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi> wr=
ote:
>
> On Mon, 21 Jan 2008, Dave Young wrote:
>
> > Please see the kernel messages following,(trigged while using some =
qemu session)
> > BTW, seems there's some e100 error message as well.
> >
> > PCI: Setting latency timer of device 0000:00:1b.0 to 64
> > e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
> > e100: Copyright(c) 1999-2006 Intel Corporation
> > ACPI: PCI Interrupt 0000:03:08.0[A] -> GSI 20 (level, low) -> IRQ 2=
0
> > modprobe:2331 conflicting cache attribute efaff000-efb00000 uncache=
d<->default
> > e100: 0000:03:08.0: e100_probe: Cannot map device registers, aborti=
ng.
> > ACPI: PCI interrupt for device 0000:03:08.0 disabled
> > e100: probe of 0000:03:08.0 failed with error -12
> > eth0:  setting full-duplex.
> > ------------[ cut here ]------------
> > WARNING: at net/ipv4/tcp_input.c:2169 tcp_mark_head_lost+0x121/0x15=
0()
> > Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event snd=
_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse snd_h=
da_intel snd_pcm snd_timer btusb rtc_cmos thermal bluetooth rtc_core se=
rio_raw intel_agp button processor sg snd rtc_lib i2c_i801 evdev agpgar=
t soundcore dcdbas 3c59x pcspkr snd_page_alloc
> > Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #4
> >  [<c0132100>] ? printk+0x0/0x20
> >  [<c0131834>] warn_on_slowpath+0x54/0x80
> >  [<c03e8df8>] ? ip_finish_output+0x128/0x2e0
> >  [<c03e9527>] ? ip_output+0xe7/0x100
> >  [<c03e8a88>] ? ip_local_out+0x18/0x20
> >  [<c03e991c>] ? ip_queue_xmit+0x3dc/0x470
> >  [<c043641e>] ? _spin_unlock_irqrestore+0x5e/0x70
> >  [<c0186be1>] ? check_pad_bytes+0x61/0x80
> >  [<c03f6031>] tcp_mark_head_lost+0x121/0x150
> >  [<c03f60ac>] tcp_update_scoreboard+0x4c/0x170
> >  [<c03f6e0a>] tcp_fastretrans_alert+0x48a/0x6b0
> >  [<c03f7d93>] tcp_ack+0x1b3/0x3a0
> >  [<c03fa14b>] tcp_rcv_established+0x3eb/0x710
> >  [<c04015c5>] tcp_v4_do_rcv+0xe5/0x100
> >  [<c0401bbb>] tcp_v4_rcv+0x5db/0x660
>
> Doh, once more these S+L things..., the rest are symptom of the first
> problem.

What is the S+L thing? Could you explain a bit?

>
> What is strange is that it doesn't show up until now, the last TCP
> changes that could have some significance are from early Dec/Nov. Is
> there some reason why you haven't seen this before this (e.g., not
> tested with similar cfg or so)?

Hmm, don't know how to answer ...

I'm a bit worried about its
> reproducability if it takes this far to see it...
>
>
> --
>  i.
>
