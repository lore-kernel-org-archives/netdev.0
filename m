From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: kernel BUG at net/ipv6/exthdrs_core.c:80!
Date: Fri, 22 Apr 2005 20:46:10 +0900 (JST)
Message-ID: <20050422.204610.96031992.yoshfuji@linux-ipv6.org>
References: <20050422113259.GX3858@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com,
	yoshfuji@linux-ipv6.org
Return-path: <linux-net-owner@vger.kernel.org>
To: matti.aarnio@zmailer.org
In-Reply-To: <20050422113259.GX3858@mea-ext.zmailer.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20050422113259.GX3858@mea-ext.zmailer.org> (at Fri, 22 Apr 2005 14:32:59 +0300), Matti Aarnio <matti.aarnio@zmailer.org> says:

> kernel BUG at net/ipv6/exthdrs_core.c:80!
> invalid operand: 0000 [#1]
> SMP DEBUG_PAGEALLOC
> Modules linked in: parport_pc lp parport w83627hf eeprom i2c_sensor i2c_isa ip_conntrack_ftp ipt_conntrack iptable_mangle ipt_state ip_conntrack ipt_REJECT iptable_filter ip_tables ip6table_filter ip6_tables md5 ipv6 dm_mod video button battery ac ohci1394 ieee1394 uhci_hcd ehci_hcd hw_random i2c_i801 i2c_core snd_intel8x0 snd_ac97_codec snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore snd_page_alloc e100 mii sk98lin dummy floppy ext3 jbd raid1 sata_sil ata_piix libata aic7xxx sd_mod scsi_mod
> CPU:    1
> EIP:    0060:[<c0309611>]    Not tainted VLI
> EFLAGS: 00010282   (2.6.11-1.1191_FC4smp) 
> EIP is at ipv6_skip_exthdr+0xb0/0x15f
> eax: fffffff2   ebx: 0000002c   ecx: f4ba0abe   edx: c5c3ef48
> esi: 000000d8   edi: 00000000   ebp: 000000da   esp: f4ba0ab0
> ds: 007b   es: 007b   ss: 0068
> Process named (pid: 2498, threadinfo=f4ba0000 task=f4ba3ad0)
> Stack: 00000002 f4ba0b17 c5c3ef48 80000000 c5c3ef48 00000028 f4ba0b58 00000000 
>        c01bd46e 00000038 c9081080 001733f8 00000001 c2017c60 c2017c60 00000001 
>        854830d2 f4ba3ad0 00000096 f4ba0afc f4ba0afc c0404488 00000001 f4ba0b2c 
> Call Trace:
>  [<c01bd46e>] selinux_parse_skb_ipv6+0x8a/0x14a
>  [<c01bd58f>] selinux_parse_skb+0x61/0x8b
>  [<c01be0fb>] selinux_ip_postroute_last+0xc9/0x222
>  [<c01be299>] selinux_ipv6_postroute_last+0x20/0x25
>  [<f8dca952>] ip6_output_finish+0x0/0xf0 [ipv6]
:

I assume that BUG was raised because of skb_header_pointer()'s failure;
which means, skb_copy_bits()'s failure. Strange to me.

Do you know what caused this?
How about disabling selinux / ip6tables?

Thanks.

--yoshfuji
