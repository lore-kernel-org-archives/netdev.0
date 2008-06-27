From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10996] New: 2.6.25 kernels spew SKB BUG:
 Invalid truesize when using ipsec/openswan
Date: Fri, 27 Jun 2008 16:40:38 -0700
Message-ID: <20080627164038.3338fb39.akpm@linux-foundation.org>
References: <bug-10996-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: ajlill@ajlc.waterloo.on.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50429 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756217AbYF0XlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 19:41:10 -0400
In-Reply-To: <bug-10996-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 27 Jun 2008 16:37:22 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10996
> 
>            Summary: 2.6.25 kernels spew SKB BUG: Invalid truesize when using
>                     ipsec/openswan
>            Product: Networking
>            Version: 2.5
>      KernelVersion: Linux version 2.6.25.9 (ajlill@ds) (gcc version 3.4.6
>                     (Debian 3.
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: low
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: ajlill@ajlc.waterloo.on.ca
> 
> 
> Latest working kernel version: 2.6.24.4
> Earliest failing kernel version:2.6.25.4

These two lines are contradictory.  Please clarify.

> Distribution: Debian etch
> Hardware Environment:
> processor       : 0
> vendor_id       : GenuineIntel
> cpu family      : 15
> model           : 4
> model name      : Intel(R) Celeron(R) CPU 2.93GHz
> stepping        : 1
> cpu MHz         : 2929.700
> cache size      : 256 KB
> fdiv_bug        : no
> hlt_bug         : no
> f00f_bug        : no
> coma_bug        : no
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 5
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
> pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe constant_tsc up pebs
> bts pni monitor ds_cpl cid xtpr
> bogomips        : 5865.13
> clflush size    : 64
> 
> Linux-i686-2.6.25.9 $ cat /proc/modules 
> xfrm_user 28040 2 - Live 0xe037d000
> xfrm4_tunnel 3976 0 - Live 0xe0226000
> af_key 39452 0 - Live 0xe0308000
> authenc 8072 5 - Live 0xe0443000
> xfrm4_mode_tunnel 3976 10 - Live 0xe0435000
> cls_u32 9100 1 - Live 0xe045e000
> sch_red 7432 1 - Live 0xe0440000
> xt_mark 3208 2 - Live 0xe0433000
> xt_layer7 12564 5 - Live 0xe0463000
> xt_length 2952 2 - Live 0xe0431000
> cls_fw 6536 14 - Live 0xe042b000
> sch_sfq 8072 14 - Live 0xe0422000
> sch_htb 17288 2 - Live 0xe0425000
> xt_TCPMSS 6536 1 - Live 0xe0400000
> xt_tcpmss 3208 1 - Live 0xe0418000
> netconsole 11044 0 - Live 0xe043c000
> configfs 28592 2 netconsole, Live 0xe0446000
> pppoe 14564 2 - Live 0xe0437000
> pppox 5396 1 pppoe, Live 0xe042e000
> iptable_mangle 4360 1 - Live 0xe0415000
> xt_MARK 3592 47 - Live 0xe0395000
> xt_conntrack 5128 1 - Live 0xe0412000
> ipt_REDIRECT 3208 1 - Live 0xe035f000
> xt_limit 3596 4 - Live 0xe0334000
> ipt_recent 10428 3 - Live 0xe041a000
> ipt_REJECT 5000 11 - Live 0xe040f000
> xt_state 3464 10 - Live 0xe0306000
> xt_tcpudp 4360 203 - Live 0xe040c000
> ipt_LOG 7052 27 - Live 0xe03f7000
> iptable_filter 4492 1 - Live 0xe03fd000
> iptable_nat 8340 1 - Live 0xe0408000
> ip_tables 15256 3 iptable_mangle,iptable_filter,iptable_nat, Live 0xe0403000
> nf_nat_pptp 4872 0 - Live 0xe03fa000
> nf_conntrack_pptp 8076 1 nf_nat_pptp, Live 0xe03a2000
> nf_conntrack_proto_gre 7176 1 nf_conntrack_pptp, Live 0xe034b000
> nf_nat_proto_gre 3852 1 nf_nat_pptp, Live 0xe0254000
> nf_nat_sip 5512 0 - Live 0xe0392000
> nf_conntrack_sip 10148 1 nf_nat_sip, Live 0xe039e000
> nf_nat_ftp 4364 0 - Live 0xe038f000
> nf_nat 20532 6
> ipt_REDIRECT,iptable_nat,nf_nat_pptp,nf_nat_proto_gre,nf_nat_sip,
> nf_nat_ftp, Live 0xe0397000
> nf_conntrack_ipv4 18716 19 iptable_nat,nf_nat, Live 0xe0377000
> nf_conntrack_ftp 10292 1 nf_nat_ftp, Live 0xe038b000
> nf_conntrack 64396 13
> xt_layer7,xt_conntrack,xt_state,iptable_nat,nf_nat_pptp,nf
> _conntrack_pptp,nf_conntrack_proto_gre,nf_nat_sip,nf_conntrack_sip,nf_nat_ftp,nf
> _nat,nf_conntrack_ipv4,nf_conntrack_ftp, Live 0xe03e6000
> xt_TARPIT 5000 2 - Live 0xe0374000
> x_tables 17804 17
> xt_mark,xt_layer7,xt_length,xt_TCPMSS,xt_tcpmss,xt_MARK,xt_con
> ntrack,ipt_REDIRECT,xt_limit,ipt_recent,ipt_REJECT,xt_state,xt_tcpudp,ipt_LOG,ip
> table_nat,ip_tables,xt_TARPIT, Live 0xe0385000
> tunnel4 4752 1 xfrm4_tunnel, Live 0xe034e000
> ipcomp 9744 0 - Live 0xe0370000
> esp4 9096 5 - Live 0xe035b000
> aead 9096 2 authenc,esp4, Live 0xe0357000
> ah4 7432 0 - Live 0xe0341000
> af_packet 23176 8 - Live 0xe0369000
> ppp_generic 28196 6 pppoe,pppox, Live 0xe0361000
> slhc 7176 1 ppp_generic, Live 0xe004c000
> ipv6 261772 34 - Live 0xe03a5000
> deflate 4872 0 - Live 0xe0327000
> zlib_deflate 19776 1 deflate, Live 0xe0351000
> ctr 6024 0 - Live 0xe0316000
> twofish 8328 0 - Live 0xe0330000
> twofish_common 13832 1 twofish, Live 0xe033c000
> camellia 22536 0 - Live 0xe0344000
> serpent 18696 0 - Live 0xe0336000
> blowfish 10376 0 - Live 0xe0323000
> des_generic 17288 0 - Live 0xe032a000
> cbc 5384 5 - Live 0xe0313000
> aes_i586 9352 5 - Live 0xe0241000
> aes_generic 31052 1 aes_i586, Live 0xe031a000
> xcbc 6416 0 - Live 0xe023e000
> sha256_generic 12808 0 - Live 0xe0301000
> sha1_generic 3720 5 - Live 0xe017e000
> crypto_null 4232 0 - Live 0xe023b000
> crypto_blkcipher 19864 9 authenc,ctr,cbc,crypto_null, Live 0xe02fb000
> dm_snapshot 20400 0 - Live 0xe024e000
> dm_mirror 29200 0 - Live 0xe0245000
> dm_mod 63032 2 dm_snapshot,dm_mirror, Live 0xe026e000
> w83627hf 25140 0 - Live 0xe0164000
> hwmon_vid 3848 1 w83627hf, Live 0xe0052000
> hwmon 4388 1 w83627hf, Live 0xe0159000
> 8250_pnp 10888 0 - Live 0xe0237000
> snd_intel8x0 34252 0 - Live 0xe021c000
> snd_ac97_codec 93884 1 snd_intel8x0, Live 0xe0256000
> ac97_bus 2952 1 snd_ac97_codec, Live 0xe00a6000
> 8250 26776 1 8250_pnp, Live 0xe0214000
> serial_core 22536 1 8250, Live 0xe0177000
> floppy 57224 0 - Live 0xe0228000
> psmouse 39368 0 - Live 0xe016c000
> snd_pcm 73640 2 snd_intel8x0,snd_ac97_codec, Live 0xe0201000
> pcspkr 4232 0 - Live 0xe015c000
> rtc 15532 0 - Live 0xe013a000
> serio_raw 7948 0 - Live 0xe00f6000
> i2c_i801 10648 0 - Live 0xe013f000
> snd_timer 24600 1 snd_pcm, Live 0xe0143000
> i2c_core 24348 1 i2c_i801, Live 0xe010b000
> snd 52744 4 snd_intel8x0,snd_ac97_codec,snd_pcm,snd_timer, Live 0xe014b000
> soundcore 9188 1 snd, Live 0xe0136000
> snd_page_alloc 11412 2 snd_intel8x0,snd_pcm, Live 0xe0132000
> rng_core 6156 0 - Live 0xe001e000
> iTCO_wdt 12724 0 - Live 0xe00ed000
> button 9496 0 - Live 0xe00f2000
> intel_agp 27112 1 - Live 0xe0103000
> agpgart 35416 1 intel_agp, Live 0xe00f9000
> sg 36168 0 - Live 0xe00d4000
> evdev 13348 0 - Live 0xe00a1000
> sr_mod 17492 0 - Live 0xe00ce000
> cdrom 36292 1 sr_mod, Live 0xe008a000
> ext3 124888 3 - Live 0xe0112000
> jbd 50736 1 ext3, Live 0xe00df000
> mbcache 9740 1 ext3, Live 0xe0024000
> sd_mod 27296 10 - Live 0xe0094000
> pata_acpi 8200 0 - Live 0xe007e000
> ata_generic 9104 0 - Live 0xe007a000
> ata_piix 22796 10 - Live 0xe0083000
> libata 150576 3 pata_acpi,ata_generic,ata_piix, Live 0xe00a8000
> dock 12188 1 libata, Live 0xe0061000
> 8139cp 23440 0 - Live 0xe0073000
> 8139too 27544 0 - Live 0xe006b000
> mii 6408 2 8139cp,8139too, Live 0xe004f000
> ehci_hcd 34336 0 - Live 0xe0057000
> uhci_hcd 25244 0 - Live 0xe0031000
> thermal 21308 0 - Live 0xe0039000
> processor 44792 1 thermal, Live 0xe0040000
> fan 5256 0 - Live 0xe0021000
> unix 29244 136 - Live 0xe0028000
> 
> Software Environment:
> Debian etch firewall using pppoe and openswan
> Problem Description:
> 
> The kernel spews hundreds of 
> SKB BUG: Invalid truesize (560) len=392, sizeof(sk_buff)=176
> With various values for truesize and len whenever ipsec tunnels are up.
> 
> No other detectible problems, except log pollution.
> 
> Steps to reproduce:
> /etc/init.d/ipsec start

