From: Andrew Morton <akpm@osdl.org>
Subject: Re: divide error: 0000 in fib6_rule_match [Re: 2.6.18-rc4-mm3]
Date: Mon, 28 Aug 2006 13:28:20 -0700
Message-ID: <20060828132820.ae12ce4f.akpm@osdl.org>
References: <20060826160922.3324a707.akpm@osdl.org>
	<20060828200716.GA4244@inferi.kami.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:180 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751473AbWH1U2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 16:28:33 -0400
To: Mattia Dongili <malattia@linux.it>
In-Reply-To: <20060828200716.GA4244@inferi.kami.home>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 28 Aug 2006 22:07:16 +0200
Mattia Dongili <malattia@linux.it> wrote:

> On Sat, Aug 26, 2006 at 04:09:22PM -0700, Andrew Morton wrote:
> > 
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.18-rc4/2.6.18-rc4-mm3/
> [...]
> >  git-net.patch
> 
> got this one when starting sshd:
> 
> [   44.412000] divide error: 0000 [#1]
> [   44.412000] 4K_STACKS PREEMPT 
> [   44.412000] last sysfs file: /devices/system/cpu/cpu0/cpufreq/ondemand/ignore_nice_load
> [   44.412000] Modules linked in: nfsd exportfs lockd sunrpc ipt_MASQUERADE iptable_nat ip_nat xt_tcpudp xt_state ip_conntrack iptable_filter ip_tables x_tables ipv6 jfs aes dm_crypt dm_mod rtc sony_acpi tun psmouse sonypi speedstep_ich speedstep_lib cpufreq_conservative cpufreq_ondemand freq_table cpufreq_powersave sd_mod usb_storage scsi_mod usbhid pcmcia snd_intel8x0 snd_ac97_codec snd_ac97_bus snd_pcm_oss snd_mixer_oss snd_pcm snd_timer intel_agp agpgart i2c_i801 snd soundcore snd_page_alloc yenta_socket rsrc_nonstatic pcmcia_core uhci_hcd usbcore evdev e100 mii pcspkr
> [   44.412000] CPU:    0
> [   44.412000] EIP:    0060:[<d1516aca>]    Not tainted VLI
> [   44.412000] EFLAGS: 00210246   (2.6.18-rc4-mm3-1 #6) 
> [   44.412000] EIP is at fib6_rule_match+0x7a/0x150 [ipv6]
> [   44.412000] eax: 00000000   ebx: cd9d4e30   ecx: d15290e0   edx: 00000000
> [   44.412000] esi: cd7d9e08   edi: cd9d4e30   ebp: cd9d4d34   esp: cd9d4d0c
> [   44.412000] ds: 007b   es: 007b   ss: 0068
> [   44.412000] Process sshd (pid: 3780, ti=cd9d4000 task=cf131590 task.ti=cd9d4000)
> [   44.412000] Stack: 00000003 c018b200 00000000 ced9df60 cd9d4d6c 00000000 ced9df60 d15290e0 
> [   44.412000]        cd7d9e08 cd9d4e30 cd9d4d58 c02c198e d15290e0 cd9d4e30 00000000 c123f380 
> [   44.412000]        cd9d4e30 cd7d9e08 cd9d4e30 cd9d4d80 d15169dc d15290a0 cd9d4e30 00000000 
> [   44.412000] Call Trace:
> [   44.412000]  [<c02c198e>] fib_rules_lookup+0x5e/0xe0
> [   44.412000]  [<d15169dc>] fib6_rule_lookup+0x3c/0xb0 [ipv6]
> [   44.412000]  [<d14f8702>] ip6_route_output+0x32/0x40 [ipv6]
> [   44.412000]  [<d14ed155>] ip6_dst_lookup_tail+0x95/0xd0 [ipv6]
> [   44.412000]  [<d14ed1a7>] ip6_dst_lookup+0x17/0x20 [ipv6]
> [   44.412000]  [<d15120ce>] ip6_datagram_connect+0x36e/0x6c0 [ipv6]
> [   44.412000]  [<c02f6829>] inet_dgram_connect+0x39/0x80
> [   44.412000]  [<c02a6ceb>] sys_connect+0x6b/0x90
> [   44.412000]  [<c02a846f>] sys_socketcall+0x9f/0x260
> [   44.412000]  [<c010325b>] syscall_call+0x7/0xb
> [   44.412000]  [<b7c7c93c>] 0xb7c7c93c
> [   44.412000]  =======================
> [   44.412000] Code: 00 00 00 89 d8 83 e0 1f 0f 85 9a 00 00 00 8b 5d 08 0f b6 53 68 84 d2 75 78 8b 55 08 8b 5d 0c 8b 4a 60 8b 43 28 31 c8 89 d1 31 d2 <f7> 71 64 85 c0 0f 94 c0 0f b6 c0 8b 5d f4 8b 75 f8 8b 7d fc 89 
> [   44.412000] EIP: [<d1516aca>] fib6_rule_match+0x7a/0x150 [ipv6] SS:ESP 0068:cd9d4d0c

I cannot work out how the heck you got a divide instruction in
fib6_rule_match().

Can you please do `make net/ipv6/fib6_rules.s', find the code which
implements fib6_rule_match() (line starting with "fib6_rule_match:") and
send that plus the next 200-odd lines?  Or just stick fib6_rules.s on a
server somewhere?  Or mail me fib6_rules.s off-list.

Thanks.
