From: Marcin Slusarz <marcin.slusarz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: option: oops on unload (2.6.27.4)
Date: Fri, 28 Nov 2008 22:32:59 +0100
Message-ID: <20081128213254.GB6750@joi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
To: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

It's not new bug - I've seen this oops many times but on much older
kernels (2.6.18, probably on 2.6.24 too).

I tried to rmmod it (and all usb modules) because sometimes it helps when
modem disconnects and can't connect again.

[25350.138850] BUG: unable to handle kernel paging request at e0857fb4
[25350.138866] IP: [<e0a22e80>] :usbcore:unlink1+0xab/0xb9
[25350.138921] *pde = 1f80f067 *pte = 00000000 
[25350.138934] Oops: 0000 [#1] PREEMPT SMP 
[25350.138945] Modules linked in: r128 drm ipt_REDIRECT ipt_MASQUERADE xt_tcpudp xt_multiport iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack iptable_filter ip_tables ppp_deflate zlib_deflate zlib_inflate bsd_comp ppp_async crc_ccitt ppp_generic slhc ipt_REJECT x_tables loop option usbserial snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm snd_timer snd 8139cp i2c_i801 floppy 8139too 3c59x psmouse intel_agp soundcore snd_page_alloc sg mii usbcore agpgart i2c_core sr_mod evdev dcdbas cdrom [last unloaded: uhci_hcd]
[25350.139052] 
[25350.139059] Pid: 2807, comm: pppd Not tainted (2.6.27.4 #5)
[25350.139065] EIP: 0060:[<e0a22e80>] EFLAGS: 00010286 CPU: 0
[25350.139088] EIP is at unlink1+0xab/0xb9 [usbcore]
[25350.139095] EAX: df9fdc00 EBX: e0857f80 ECX: fffffffe EDX: dafe5e80
[25350.139101] ESI: df9fdc00 EDI: dafe5e80 EBP: dad89e80 ESP: dad89e6c
[25350.139107]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[25350.139114] Process pppd (pid: 2807, ti=dad88000 task=d9614380 task.ti=dad88000)
[25350.139119] Stack: fffffffe 00000246 dafe5e80 daff3480 dafe56b8 dad89e8c e0a23672 dafe5e80 
[25350.139140]        dad89eb0 e0a240fc 00000246 dafe56bc dafe5680 daff3480 dafe56b8 00000000 
[25350.139160]        dafe56b8 dad89ecc e088e8fc dece9000 decf3800 e0890ca0 dece9000 dece90c4 
[25350.139181] Call Trace:
[25350.139188]  [<e0a23672>] ? usb_hcd_unlink_urb+0x15/0x22 [usbcore]
[25350.139218]  [<e0a240fc>] ? usb_kill_urb+0x4b/0xc2 [usbcore]
[25350.139246]  [<e088e8fc>] ? option_close+0x7b/0x9b [option]
[25350.139267]  [<e08ab741>] ? serial_close+0x82/0xf3 [usbserial]
[25350.139285]  [<c0210fc3>] ? release_dev+0x180/0x3c3
[25350.139302]  [<c013b450>] ? __lock_acquire+0x651/0x697
[25350.139315]  [<c0211218>] ? tty_release+0x12/0x1c
[25350.139324]  [<c0167617>] ? __fput+0x99/0x13b
[25350.139336]  [<c016790e>] ? fput+0x17/0x19
[25350.139345]  [<c01652ba>] ? filp_close+0x50/0x5a
[25350.139355]  [<c01662c6>] ? sys_close+0x73/0xab
[25350.139364]  [<c0102dad>] ? sysenter_do_call+0x12/0x35
[25350.139376]  =======================
[25350.139380] Code: 89 f0 e8 f7 fe ff ff b8 84 91 a3 e0 e8 30 3c 8a df 8b 55 f0 b8 84 91 a3 e0 e8 b2 40 8a df eb 10 8b 9e b4 00 00 00 8b 4d ec 89 f0 <ff> 53 34 89 c3 89 d8 5f 5a 5b 5e 5f 5d c3 55 89 e5 57 56 53 83 
[25350.139497] EIP: [<e0a22e80>] unlink1+0xab/0xb9 [usbcore] SS:ESP 0068:dad89e6c
[25350.139527] ---[ end trace 8506998287f38ab7 ]---

Full dmesg and config can be found at:
http://www.kadu.net/~joi/kernel/2008.11.28/option-usb.oops/

Marcin
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
