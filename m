From: Patrick McHardy <kaber@trash.net>
Subject: Re: [BUG] crashes with kvm/nat networking and net-next
Date: Wed, 12 May 2010 13:18:17 +0200
Message-ID: <4BEA8E79.9000406@trash.net>
References: <20100511202544.267d33ee@nehalam> <1273649526.2621.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Bart De Schuymer <bdschuym@pandora.be>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63171 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755572Ab0ELLSU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 07:18:20 -0400
In-Reply-To: <1273649526.2621.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le mardi 11 mai 2010 =E0 20:25 -0700, Stephen Hemminger a =E9crit :
>> This is a regression that is showing up now in net-next, not sure wh=
at
>> changed recently in bridge netfilter that could be causing it?
>>
>> [ 4593.956206] BUG: unable to handle kernel NULL pointer dereference=
 at 0000000000000018
>> [ 4593.956219] IP: [<ffffffffa03357a4>] br_nf_forward_finish+0x154/0=
x170 [bridge]
>> [ 4593.956232] PGD 195ece067 PUD 1ba005067 PMD 0=20
>> [ 4593.956241] Oops: 0000 [#1] SMP=20
>> [ 4593.956248] last sysfs file: /sys/devices/LNXSYSTM:00/LNXSYBUS:00=
/PNP0A08:00/device:08/ATK0110:00/hwmon/hwmon0/temp2_label
>> [ 4593.956253] CPU 3=20
>> [ 4593.956256] Modules linked in: netconsole configfs hid_belkin tun=
 ntfs vfat msdos fat autofs4 binfmt_misc ipt_MASQUERADE iptable_nat nf_=
nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT x=
t_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm=
 radeon ttm drm_kms_helper drm i2c_algo_bit snd_hda_codec_analog ipv6 s=
nd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm =
snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event s=
nd_seq snd_timer snd_seq_device psmouse asus_atk0110 snd serio_raw soun=
dcore snd_page_alloc usbhid mvsas libsas scsi_transport_sas floppy sky2=
 e1000e [last unloaded: netconsole]
>> [ 4593.956375]=20
>> [ 4593.956380] Pid: 29512, comm: kvm Not tainted 2.6.34-rc7-net #195=
 P6T DELUXE/System Product Name
>> [ 4593.956384] RIP: 0010:[<ffffffffa03357a4>]  [<ffffffffa03357a4>] =
br_nf_forward_finish+0x154/0x170 [bridge]
>> [ 4593.956395] RSP: 0018:ffff880001e63b78  EFLAGS: 00010246
>> [ 4593.956399] RAX: 0000000000000608 RBX: ffff880057181700 RCX: ffff=
8801b813d000
>> [ 4593.956402] RDX: 0000000000000000 RSI: 0000000000000002 RDI: ffff=
880057181700
>> [ 4593.956406] RBP: ffff880001e63ba8 R08: ffff8801b9d97000 R09: ffff=
ffffa0335650
>> [ 4593.956410] R10: 0000000000000000 R11: 0000000000000000 R12: ffff=
8801b813d000
>> [ 4593.956413] R13: ffffffff81ab3940 R14: ffff880057181700 R15: 0000=
000000000002
>> [ 4593.956418] FS:  00007fc40d380710(0000) GS:ffff880001e60000(0000)=
 knlGS:0000000000000000
>> [ 4593.956422] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
>> [ 4593.956426] CR2: 0000000000000018 CR3: 00000001ba1d7000 CR4: 0000=
0000000026e0
>> [ 4593.956429] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000=
000000000000
>> [ 4593.956433] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000=
000000000400
>> [ 4593.956437] Process kvm (pid: 29512, threadinfo ffff8801ba566000,=
 task ffff8801b8003870)
>> [ 4593.956441] Stack:
>> [ 4593.956443]  0000000100000020 ffff880001e63ba0 ffff880001e63ba0 f=
fff880057181700
>> [ 4593.956451] <0> ffffffffa0335650 ffffffff81ab3940 ffff880001e63bd=
8 ffffffffa03350e6
>> [ 4593.956462] <0> ffff880001e63c40 000000000000024d ffff88005718170=
0 0000000080000000
>> [ 4593.956474] Call Trace:
>> [ 4593.956478]  <IRQ>=20
>> [ 4593.956488]  [<ffffffffa0335650>] ? br_nf_forward_finish+0x0/0x17=
0 [bridge]
>> [ 4593.956496]  [<ffffffffa03350e6>] NF_HOOK_THRESH+0x56/0x60 [bridg=
e]
>> [ 4593.956504]  [<ffffffffa0335282>] br_nf_forward_arp+0x112/0x120 [=
bridge]
>> [ 4593.956511]  [<ffffffff813f7184>] nf_iterate+0x64/0xa0
>> [ 4593.956519]  [<ffffffffa032f920>] ? br_forward_finish+0x0/0x60 [b=
ridge]
>> [ 4593.956524]  [<ffffffff813f722c>] nf_hook_slow+0x6c/0x100
>> [ 4593.956531]  [<ffffffffa032f920>] ? br_forward_finish+0x0/0x60 [b=
ridge]
>> [ 4593.956538]  [<ffffffffa032f800>] ? __br_forward+0x0/0xc0 [bridge=
]
>> [ 4593.956545]  [<ffffffffa032f86d>] __br_forward+0x6d/0xc0 [bridge]
>> [ 4593.956550]  [<ffffffff813c5d8e>] ? skb_clone+0x3e/0x70
>=20
> Not sure, but br_nf_forward_ip() has following check :
>=20
> if (!skb->nf_bridge)
> 	return NF_ACCEPT;
>=20
> while br_nf_forward_arp() missed this check ...
>=20
> So we can dereference null pointer later

That looks correct to me, offset 0x18 would be nf_bridge_info->mask.
Bart, please review, thanks.

>=20
> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
> index 93f80fe..cd2e5f5 100644
> --- a/net/bridge/br_netfilter.c
> +++ b/net/bridge/br_netfilter.c
> @@ -723,6 +723,9 @@ static unsigned int br_nf_forward_arp(unsigned in=
t hook, struct sk_buff *skb,
>  		return NF_ACCEPT;
>  #endif
> =20
> +	if (!skb->nf_bridge)
> +		return NF_ACCEPT;
> +
>  	if (skb->protocol !=3D htons(ETH_P_ARP)) {
>  		if (!IS_VLAN_ARP(skb))
>  			return NF_ACCEPT;
>=20
>=20

