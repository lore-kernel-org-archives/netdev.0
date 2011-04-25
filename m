From: Held Bernhard <berny156@gmx.de>
Subject: Re: Oops in 2.6.39 include/net/dst.h: dst_metrics_write_ptr() running
 l2tp over ipsec
Date: Mon, 25 Apr 2011 11:52:16 +0200
Message-ID: <4DB54450.90806@gmx.de>
References: <4DB4A619.9080600@gmx.de> <1303718852.2747.103.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1303718852.2747.103.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 25.04.2011 10:07, schrieb Eric Dumazet:
> From: Held Bernhard<berny156@gmx.de>
>
> Le lundi 25 avril 2011 =C3=A0 00:37 +0200, Held Bernhard a =C3=A9crit=
 :
>> Hi,
>>
>> I'm starting l2tp over ipsec (racoon, openl2tp) in a little script t=
o
>> establish a VPN to my company. 2.6.38.x runs fine, but since 2.6.39-=
rc1
>> (exactly commit 62fa8a "net: Implement read-only protection and COW'=
ing
>> of metrics.") the kernel throws an oops. openl2tp is killed; after a=
 2nd
>> start of openl2tp the VPN is established and my PC continues to run
>> normally. The oops is 100% reproducible.
>
> ...
>
>> Please tell me if you need more information!
>>
>> Thanks,
>> Bernhard
>> -
>
> Thanks for your report and patch.
>
> Maybe following patch is the way to fix this, please test it.
>
>
> [PATCH] net: provide cow_metrics() methods to blackhole dst_ops
>
> Since commit 62fa8a846d7d (net: Implement read-only protection and CO=
W'ing
> of metrics.) the kernel throws an oops.
>
> [  101.620985] BUG: unable to handle kernel NULL pointer dereference =
at
>             (null)
> [  101.621050] IP: [<           (null)>]           (null)
> [  101.621084] PGD 6e53c067 PUD 3dd6a067 PMD 0
> [  101.621122] Oops: 0010 [#1] SMP
> [  101.621153] last sysfs file: /sys/devices/virtual/ppp/ppp/uevent
> [  101.621192] CPU 2
> [  101.621206] Modules linked in: l2tp_ppp pppox ppp_generic slhc
> l2tp_netlink l2tp_core deflate zlib_deflate twofish_x86_64
> twofish_common des_generic cbc ecb sha1_generic hmac af_key
> iptable_filter snd_pcm_oss snd_mixer_oss snd_seq snd_seq_device loop
> snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec
> snd_pcm snd_timer snd i2c_i801 iTCO_wdt psmouse soundcore snd_page_al=
loc
> evdev uhci_hcd ehci_hcd thermal
> [  101.621552]
> [  101.621567] Pid: 5129, comm: openl2tpd Not tainted 2.6.39-rc4-Quad=
 #3
> Gigabyte Technology Co., Ltd. G33-DS3R/G33-DS3R
> [  101.621637] RIP: 0010:[<0000000000000000>]  [<           (null)>] =
  (null)
> [  101.621684] RSP: 0018:ffff88003ddeba60  EFLAGS: 00010202
> [  101.621716] RAX: ffff88003ddb5600 RBX: ffff88003ddb5600 RCX:
> 0000000000000020
> [  101.621758] RDX: ffffffff81a69a00 RSI: ffffffff81b7ee61 RDI:
> ffff88003ddb5600
> [  101.621800] RBP: ffff8800537cd900 R08: 0000000000000000 R09:
> ffff88003ddb5600
> [  101.621840] R10: 0000000000000005 R11: 0000000000014b38 R12:
> ffff88003ddb5600
> [  101.621881] R13: ffffffff81b7e480 R14: ffffffff81b7e8b8 R15:
> ffff88003ddebad8
> [  101.621924] FS:  00007f06e4182700(0000) GS:ffff88007fd00000(0000)
> knlGS:0000000000000000
> [  101.621971] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  101.622005] CR2: 0000000000000000 CR3: 0000000045274000 CR4:
> 00000000000006e0
> [  101.622046] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [  101.622087] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> [  101.622129] Process openl2tpd (pid: 5129, threadinfo
> ffff88003ddea000, task ffff88003de9a280)
> [  101.622177] Stack:
> [  101.622191]  ffffffff81447efa ffff88007d3ded80 ffff88003de9a280
> ffff88007d3ded80
> [  101.622245]  0000000000000001 ffff88003ddebbb8 ffffffff8148d5a7
> 0000000000000212
> [  101.622299]  ffff88003dcea000 ffff88003dcea188 ffffffff00000001
> ffffffff81b7e480
> [  101.622353] Call Trace:
> [  101.622374]  [<ffffffff81447efa>] ? ipv4_blackhole_route+0x1ba/0x2=
10
> [  101.622415]  [<ffffffff8148d5a7>] ? xfrm_lookup+0x417/0x510
> [  101.622450]  [<ffffffff8127672a>] ? extract_buf+0x9a/0x140
> [  101.622485]  [<ffffffff8144c6a0>] ? __ip_flush_pending_frames+0x70=
/0x70
> [  101.622526]  [<ffffffff8146fbbf>] ? udp_sendmsg+0x62f/0x810
> [  101.622562]  [<ffffffff813f98a6>] ? sock_sendmsg+0x116/0x130
> [  101.622599]  [<ffffffff8109df58>] ? find_get_page+0x18/0x90
> [  101.622633]  [<ffffffff8109fd6a>] ? filemap_fault+0x12a/0x4b0
> [  101.622668]  [<ffffffff813fb5c4>] ? move_addr_to_kernel+0x64/0x90
> [  101.622706]  [<ffffffff81405d5a>] ? verify_iovec+0x7a/0xf0
> [  101.622739]  [<ffffffff813fc772>] ? sys_sendmsg+0x292/0x420
> [  101.622774]  [<ffffffff810b994a>] ? handle_pte_fault+0x8a/0x7c0
> [  101.622810]  [<ffffffff810b76fe>] ? __pte_alloc+0xae/0x130
> [  101.622844]  [<ffffffff810ba2f8>] ? handle_mm_fault+0x138/0x380
> [  101.622880]  [<ffffffff81024af9>] ? do_page_fault+0x189/0x410
> [  101.622915]  [<ffffffff813fbe03>] ? sys_getsockname+0xf3/0x110
> [  101.622952]  [<ffffffff81450c4d>] ? ip_setsockopt+0x4d/0xa0
> [  101.622986]  [<ffffffff813f9932>] ? sockfd_lookup_light+0x22/0x90
> [  101.623024]  [<ffffffff814b61fb>] ? system_call_fastpath+0x16/0x1b
> [  101.623060] Code:  Bad RIP value.
> [  101.623090] RIP  [<           (null)>]           (null)
> [  101.623125]  RSP<ffff88003ddeba60>
> [  101.623146] CR2: 0000000000000000
> [  101.650871] ---[ end trace ca3856a7d8e8dad4 ]---
> [  101.651011] __sk_free: optmem leakage (160 bytes) detected.
>
> The oops happens in dst_metrics_write_ptr()
> include/net/dst.h:124: return dst->ops->cow_metrics(dst, p);
>
> dst->ops->cow_metrics is NULL and causes the oops.
>
> Provide cow_metrics() methods, like we did in commit 214f45c91bb
> (net: provide default_advmss() methods to blackhole dst_ops)
>
> Signed-off-by: Held Bernhard<berny156@gmx.de>
> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
> ---
>   net/ipv4/route.c |    7 +++++++
>   net/ipv6/route.c |    7 +++++++
>   2 files changed, 14 insertions(+)
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index c1acf69..99e6e4b 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2690,6 +2690,12 @@ static void ipv4_rt_blackhole_update_pmtu(stru=
ct dst_entry *dst, u32 mtu)
>   {
>   }
>
> +static u32 *ipv4_rt_blackhole_cow_metrics(struct dst_entry *dst,
> +					  unsigned long old)
> +{
> +	return NULL;
> +}
> +
>   static struct dst_ops ipv4_dst_blackhole_ops =3D {
>   	.family			=3D	AF_INET,
>   	.protocol		=3D	cpu_to_be16(ETH_P_IP),
> @@ -2698,6 +2704,7 @@ static struct dst_ops ipv4_dst_blackhole_ops =3D=
 {
>   	.default_mtu		=3D	ipv4_blackhole_default_mtu,
>   	.default_advmss		=3D	ipv4_default_advmss,
>   	.update_pmtu		=3D	ipv4_rt_blackhole_update_pmtu,
> +	.cow_metrics		=3D	ipv4_rt_blackhole_cow_metrics,
>   };
>
>   struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_=
entry *dst_orig)
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 843406f..93b10e6 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -153,6 +153,12 @@ static void ip6_rt_blackhole_update_pmtu(struct =
dst_entry *dst, u32 mtu)
>   {
>   }
>
> +static u32 *ip6_rt_blackhole_cow_metrics(struct dst_entry *dst,
> +					 unsigned long old)
> +{
> +	return NULL;
> +}
> +
>   static struct dst_ops ip6_dst_blackhole_ops =3D {
>   	.family			=3D	AF_INET6,
>   	.protocol		=3D	cpu_to_be16(ETH_P_IPV6),
> @@ -161,6 +167,7 @@ static struct dst_ops ip6_dst_blackhole_ops =3D {
>   	.default_mtu		=3D	ip6_blackhole_default_mtu,
>   	.default_advmss		=3D	ip6_default_advmss,
>   	.update_pmtu		=3D	ip6_rt_blackhole_update_pmtu,
> +	.cow_metrics		=3D	ip6_rt_blackhole_cow_metrics,
>   };
>
>   static const u32 ip6_template_metrics[RTAX_MAX] =3D {

Your patch works flawlessly.

Thanks for the quick response!

Bernhard
