From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Oops in authenc: 2.6.26.3
Date: Wed, 20 Aug 2008 20:31:37 -0700
Message-ID: <20080820203137.dfc1264e.akpm@linux-foundation.org>
References: <20080820203245.ea01ff39.kernel1@cyberdogtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Matt LaPlante <kernel1@cyberdogtech.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20080820203245.ea01ff39.kernel1@cyberdogtech.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(cc's added)

On Wed, 20 Aug 2008 20:32:45 -0500 Matt LaPlante <kernel1@cyberdogtech.com> wrote:

> After upgrading one of my IPSec connected boxes from 2.6.25.x to 2.6.26.x I began to experience the following oopses.  I haven't identified what exactly causes it to trigger, but it has occurred repeatedly, anywhere from 5 to 15 minutes of the box booting the new kernel and running.  I'm not sure what other details are relevant for debugging, so I'll wait for feedback on what specific data is needed.
> 
> Ubuntu 8.04
> racoon 1:0.6.7-1.1ubuntu1
> ipsec-tools 1:0.6.7-1.1ubuntu1
> 
> BUG: unable to handle kernel paging request at 5684c077
> IP: [<cc96856b>] :authenc:crypto_authenc_givencrypt_done+0x1b/0x20
> Oops: 0000 [#1]
> Modules linked in: authenc esp4 aead xfrm4_mode_tunnel tun iptable_raw xt_policy
>  xt_multiport ipt_ULOG ipt_TTL ipt_REJECT ipt_REDIRECT ipt_recent ipt_NETMAP ipt
> _MASQUERADE ipt_LOG ipt_ECN ipt_ah ipt_addrtype xt_tcpmss xt_pkttype xt_NFQUEUE
> xt_MARK xt_mark xt_mac xt_limit xt_length xt_helper xt_conntrack xt_CONNMARK xt_
> connmark xt_CLASSIFY iptable_nat nf_nat nf_conntrack_ipv4 iptable_mangle nfnetli
> nk iptable_filter ip_tables ip6t_LOG nf_conntrack_ipv6 xt_state nf_conntrack xt_
> tcpudp ip6table_filter ip6_tables x_tables sit tunnel4 deflate zlib_deflate zlib
> _inflate ctr twofish_i586 twofish_common serpent blowfish des_generic cbc aes_i5
> 86 aes_generic xcbc sha256_generic sha1_generic md5 crypto_null crypto_blkcipher
>  af_key psmouse af_packet ipv6 evdev pcspkr sd_mod sg via_rhine ata_piix ata_gen
> eric
> 
> Pid: 4, comm: events/0 Not tainted (2.6.26.3-Gateway.v11 #2)
> EIP: 0060:[<cc96856b>] EFLAGS: 00010296 CPU: 0
> EIP is at crypto_authenc_givencrypt_done+0x1b/0x20 [authenc]
> EAX: 5684c06f EBX: cbaef540 ECX: 5684c06f EDX: 00000000
> ESI: cbaef540 EDI: cbaef530 EBP: cb1a3170 ESP: cb825f74
>  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
> Process events/0 (pid: 4, ti=cb824000 task=cb81d120 task.ti=cb824000)
> Stack: 00000000 cc84f6c0 cb1a318c cb8029c0 cc84f670 cb8029c0 c01267fb cb1d8760
>        cb81007b c011007b c0350000 cb8029c0 cb8029c8 c0126ef0 00000000 c0126f49
>        00000000 cb81d120 c0129880 cb825fc0 cb825fc0 fffffffc cb8029c0 c0126ef0
> Call Trace:
> [<cc84f6c0>] async_chainiv_do_postponed+0x50/0x80 [crypto_blkcipher]
> [<cc84f670>] async_chainiv_do_postponed_0x0/0x80 [crypto_blkcipher]
> [<c01267fb>] run_workqueue+0x8b/0x110
> [<c011007b>] handle_vm86_fault+0x5b/0x7c0
> [<c0126ef0>] worker_thread+0x0/0x90
> [<c0126f49>] worker_thread+0x59/0x90
> [<c0129880>] autoremove_wake_function+0x0/0x40
> [<c0126ef0>] worker_thread+0x0/0x90
> [<c0129502>] kthread+0x42/0x70
> [<c01294c0>] kthread+0x0/0x70
> [<c0103953>] kernel_thread_helper+0x7/0x14
> Code: 09 03 e9 3f ff ff ff 89 f6 8d bc 27 00 00 00 00 85 d2 53 89 c3 75 0f 8b 40 
> 0c 31 c9 8b 50 38 e8 fc fb ff ff 89 c2 8b 4b 0c 89 c8 <ff> 51 08 5b c3 85 d2 53
> 89 c3 75 18 8b 40 0c 8b 48 10 8d 50 58
> EIP: [<cc96856b>] crypto_authenc_givencrypt_done+0x1b/0x20 [authenc] SS:ESP 0068:cb825f74
> Kernel panic - not syncing: Fatal exception in interrupt
> 
