From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: NULL pointer derefence since 2.6.27 in (e)poll
Date: Sun, 19 Oct 2008 14:45:04 +0300
Message-ID: <84144f020810190445r12154ae0p271037ae130b653b@mail.gmail.com>
References: <6F31A6373E3D42EDAED26A994BA0830D@Seven>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"Linux Netdev List" <netdev@vger.kernel.org>
To: "Ben Castricum" <lk0810@bencastricum.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:45569 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898AbYJSLpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Oct 2008 07:45:05 -0400
Received: by wa-out-1112.google.com with SMTP id v27so685561wah.21
        for <netdev@vger.kernel.org>; Sun, 19 Oct 2008 04:45:04 -0700 (PDT)
In-Reply-To: <6F31A6373E3D42EDAED26A994BA0830D@Seven>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 19, 2008 at 2:02 PM, Ben Castricum <lk0810@bencastricum.nl> wrote:
> I am getting this bug reports almost daily since about 2.6.27. I saved the
> output of all of them, but they are all nearly identical, so I just included
> the first one. After the report networking seems unstable and the system
> requires a reboot.
>
> My .config can be found at http://www.bencastricum.nl/.config
>
> I hope this helps.
>
> Ben
>
>
> BUG: unable to handle kernel NULL pointer dereference at 00000020
> IP: [<b0254b74>] sock_poll+0xc/0x12
> *pde = 00000000
> Oops: 0000 [#1] SMP
> last sysfs file:
> /sys/devices/pci0000:00/0000:00:1f.3/i2c-adapter/i2c-0/0-002e/cpu0_vid
> Modules linked in: ipt_MASQUERADE ipt_REJECT ipt_LOG xt_recent xt_tcpudp
> xt_state iptable_filter nf_conntrack_ftp iptable_nat ip_tables nf_nat
> x_tables nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 af_packet usb_storage
> usbhid 8139too mii tg3 libphy cdc_acm ehci_hcd uhci_hcd usbcore lm85
> hwmon_vid i2c_i801 softdog rtc ext2 [last unloaded: firmware_class]
>
> Pid: 1717, comm: squid Not tainted (2.6.27-05178-g2e532d6 #111) HP d530
> SFF(PL110ES)
> EIP: 0060:[<b0254b74>] EFLAGS: 00010246 CPU: 0
> EIP is at sock_poll+0xc/0x12
> EAX: ea872d80 EBX: 00000000 ECX: 00000000 EDX: eee50e00
> ESI: e9a9bf00 EDI: ef304b80 EBP: ea84af44 ESP: ea84af40
> DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> Process squid (pid: 1717, ti=ea84a000 task=ea96e330 task.ti=ea84a000)
> Stack:
> e9a9bf0c ea84afb0 b017ff04 ea84af9c 00000002 00000000 eabe1300 ef304b98
> 00000003 ef304bac ef304ba4 e9a9bf0c ef304ba0 ef304b94 00000046 ef304b84
> ea84af9c b03ce000 b014248d ea84af94 b0126765 ea84afb0 b0105909 ea84af9c
> Call Trace:
> [<b017ff04>] ? sys_epoll_wait+0x245/0x3a7
> [<b014248d>] ? handle_fasteoi_irq+0x0/0xad
> [<b0126765>] ? irq_exit+0x53/0x77
> [<b0105909>] ? do_IRQ+0xae/0xc4
> [<b0103905>] ? sysenter_do_call+0x12/0x25
> Code: 8b 58 54 b8 ea ff ff ff 85 db 74 0c ff 75 0c ff 75 08 89 f0 ff d3 5a
> 59 8d 65 f8 5b 5e 5d c3 55 89 e5 53 89 d1 8b 50 6c 8b 5a 0c <ff> 53 20 5b 5d
> c3 55 89 e5 53 89 d1 8b 50 6c 8b 5a 0c ff 53 4c
> EIP: [<b0254b74>] sock_poll+0xc/0x12 SS:ESP 0068:ea84af40
> ---[ end trace 6e50fb78d788d751 ]---

Looks like file->private is NULL in sock_poll() so I'm cc'ing netdev.
