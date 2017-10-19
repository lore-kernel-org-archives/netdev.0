From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 32/58] isdn/gigaset: Convert timers to use timer_setup()
Date: Thu, 19 Oct 2017 23:20:28 +0200
Message-ID: <1508448028.2274.21.camel@tiscali.nl>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
         <1508200182-104605-33-git-send-email-keescook@chromium.org>
         <1508447002.2274.14.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
        Johan Hovold <johan@kernel.org>,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508447002.2274.14.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-10-19 at 23:03 +0200, Paul Bolle wrote:
> On Mon, 2017-10-16 at 17:29 -0700, Kees Cook wrote:
> > In preparation for unconditionally passing the struct timer_list pointer to
> > all timer callbacks, switch to using the new timer_setup() and from_timer()
> > to pass the timer pointer explicitly.
> 
> Acked-by: Paul Bolle <pebolle@tiscali.nl>

I have to take this back, sorry!

> For the record: this patch made me nervous but survived the rigorous testing I
> threw at it. (Ie, dialing up using bas_gigaset and downloading almost 20 MB in
> just over an hour. Whoot! That's more than good enough to ack this patch.)
> 
> There was some cleanup I had in mind to make this patch more straightforward.
> But that can wait until someone finds a way to hit an issue with this patch.
> We'll see.

That someone turns out to be me, doing "modprobe -r bas_gigaset":

<1>[30143.538135] BUG: unable to handle kernel NULL pointer dereference at 000001e9
<1>[30143.538154] IP: mutex_lock+0x19/0x30
<6>[30143.538157] *pde = 00000000 
<5>[30143.538162] Oops: 0002 [#1] SMP
<5>[30143.538165] Modules linked in: bas_gigaset(OE-) gigaset vfat fat uas usb_storage ppp_deflate bsd_comp ppp_synctty ppp_generic slhc capi kernelcapi fuse xt_CHECKSUM ipt_MASQUERADE nf_nat_masquerade_ipv4 tun nf_conntrack_netbios_ns nf_conntrack_broadcast xt_CT ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack libcrc32c iptable_mangle iptable_raw iptable_security ebtable_filter ebtables ip6table_filter ip6_tables sunrpc snd_intel8x0 snd_ac97_codec gpio_ich ac97_bus ppdev iTCO_wdt iTCO_vendor_support lpc_ich snd_seq snd_seq_device snd_pcm pcspkr i
 2c_i801 thinkpad_acpi
<5>[30143.538228]  snd_timer snd irda(C) soundcore parport_pc rfkill parport acpi_cpufreq i915 i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops sdhci_pci drm tg3 sdhci mmc_core ata_generic serio_raw yenta_socket ptp pata_acpi pps_core video [last unloaded: gigaset]
<0>[30143.538257] CPU: 0 PID: 22085 Comm: modprobe Tainted: G         C OE   4.14.0-0.rc4.1.local0.fc26.i686 #1
<0>[30143.538260] Hardware name: IBM 2525FAG/2525FAG, BIOS 74ET64WW (2.09 ) 12/14/2006
<0>[30143.538263] task: f6671100 task.stack: c77c6000
<5>[30143.538267] EIP: mutex_lock+0x19/0x30
<5>[30143.538269] EFLAGS: 00010246 CPU: 0
<5>[30143.538272] EAX: 00000000 EBX: 000001e9 ECX: 00000001 EDX: f6671100
<5>[30143.538275] ESI: 000001e9 EDI: 011c8f98 EBP: c77c7ef4 ESP: c77c7ef0
<5>[30143.538278]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
<5>[30143.538281] CR0: 80050033 CR2: 000001e9 CR3: 16d2d000 CR4: 000006d0
<0>[30143.538284] Call Trace:
<0>[30143.538300]  gigaset_shutdown+0x28/0x130 [gigaset]
<0>[30143.538307]  ? find_module_all+0x62/0x80
<0>[30143.538314]  bas_gigaset_exit+0x31/0x1077 [bas_gigaset]
<0>[30143.538319]  SyS_delete_module+0x19c/0x240
<0>[30143.538325]  ? ____fput+0xd/0x10
<0>[30143.538330]  do_fast_syscall_32+0x71/0x1a0
<0>[30143.538335]  entry_SYSENTER_32+0x4e/0x7c
<5>[30143.538337] EIP: 0xb7fb5cd9
<5>[30143.538339] EFLAGS: 00000206 CPU: 0
<5>[30143.538342] EAX: ffffffda EBX: 011c8fd4 ECX: 00000800 EDX: 011c8fd4
<5>[30143.538345] ESI: 011c8f98 EDI: 011c8f98 EBP: 011c8fd4 ESP: bf8278f8
<5>[30143.538348]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
<0>[30143.538351] Code: 8e fb ff ff 5d c3 8d b6 00 00 00 00 8d bf 00 00 00 00 3e 8d 74 26 00 55 89 e5 53 89 c3 e8 60 e7 ff ff 64 8b 15 40 c9 82 c7 31 c0 <3e> 0f b1 13 85 c0 74 07 89 d8 e8 b8 ff ff ff 5b 5d c3 90 8d 74
<0>[30143.538399] EIP: mutex_lock+0x19/0x30 SS:ESP: 0068:c77c7ef0
<5>[30143.538402] CR2: 00000000000001e9
<4>[30143.538406] ---[ end trace 3e60af64adfe7e14 ]---

I'll have to ask for some patience so I can find out what's going on. (Very
likely: using urb->context beyond it's lifetime.) Expect something by early
next week. Is that OK with you?

Sorry for the noise,


Paul Bolle
