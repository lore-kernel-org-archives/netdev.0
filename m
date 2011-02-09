From: hayeswang <hayeswang@realtek.com>
Subject: RE: Realtek r8168C / r8169 driver VLAN TAG stripping
Date: Wed, 9 Feb 2011 17:51:54 +0800
Message-ID: <CD09B45F37004B06A86638CA387A191A@realtek.com.tw>
References: <AANLkTi=uNKMj_gs_bKRQ1tQa0TMwdnyrtVcR5JPNpmJv@mail.gmail.com><AANLkTikoXfgHrJyMbe6A_HmvXT_QRo55w76st5Wo0hSv@mail.gmail.com><20110118012146.GA3704@electric-eye.fr.zoreil.com><AANLkTimA1C=trH+WGpBdPU=vBf-cN+xB4Br3+vJb-Qum@mail.gmail.com><20110127150744.GA7925@electric-eye.fr.zoreil.com><AANLkTi=OwsMO8x9AOy=MmohU4SSQcv+o=TvwNs0NNsQR@mail.gmail.com><20110127165031.GA7966@electric-eye.fr.zoreil.com><AANLkTin17BgJDdTbSMork8XEw4PVz_KrVBZvHdQwTRNH@mail.gmail.com><20110128120624.GA8100@electric-eye.fr.zoreil.com><1296479698.8750.55.camel@ceranb.intra.cera.cz><20110201101253.GA8681@electric-eye.fr.zoreil.com> <AANLkTin+MkXrqpkcKxUbMk9UDAtYz3H02Ka+CjGxJQRB@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: 'Ivan Vecera' <ivecera@redhat.com>, <netdev@vger.kernel.org>
To: 'Anand Raj Manickam' <anandrm@gmail.com>,
	'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:50264 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753568Ab1BIJwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Feb 2011 04:52:23 -0500
In-Reply-To: <AANLkTin+MkXrqpkcKxUbMk9UDAtYz3H02Ka+CjGxJQRB@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I have tested 8168C with RTL_GIGA_MAC_VER_22 . It seems fine with VLAN. My
platform is using Fedora 14. I connect my linux platform with windows one
directly because I don't have a switch supporting VLAN. I set VLAN both windows
side and Linux side and it works well. For the windows side, I use 8111D.

$ uname -a
Linux fc14.localdomain 2.6.35.10-74.fc14.i686 #1 SMP Thu Dec 23 16:17:40 UTC
2010 i686 i686 i386 GNU/Linux

$ ethtool -i eth4
driver: r8169
version: 2.3LK-NAPI
firmware-version: 
bus-info: 0000:04:00.0

$ ifconfig eth4.10
eth4.10   Link encap:Ethernet  HWaddr 00:E0:4C:68:00:1B  
          inet addr:192.168.123.112  Bcast:192.168.123.255  Mask:255.255.255.0
          inet6 addr: fe80::2e0:4cff:fe68:1b/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:6060686 errors:0 dropped:0 overruns:0 frame:0
          TX packets:7154774 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:162285185 (154.7 MiB)  TX bytes:188567970 (179.8 MiB)

$ cat /proc/cpuinfo
processor	: 0
vendor_id	: GenuineIntel
cpu family	: 15
model		: 6
model name	: Intel(R) Pentium(R) D CPU 3.00GHz
stepping	: 2
cpu MHz		: 3000.000
cache size	: 2048 KB
physical id	: 0
siblings	: 2
core id		: 0
cpu cores	: 2
apicid		: 0
initial apicid	: 0
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 6
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic mtrr pge mca cmov pat
pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx lm constant_tsc pebs
bts pni dtes64 monitor ds_cpl vmx cid cx16 xtpr pdcm lahf_lm tpr_shadow
bogomips	: 6018.47
clflush size	: 64
cache_alignment	: 128
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 1
vendor_id	: GenuineIntel
cpu family	: 15
model		: 6
model name	: Intel(R) Pentium(R) D CPU 3.00GHz
stepping	: 2
cpu MHz		: 3000.000
cache size	: 2048 KB
physical id	: 0
siblings	: 2
core id		: 1
cpu cores	: 2
apicid		: 1
initial apicid	: 1
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 6
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic mtrr pge mca cmov pat
pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx lm constant_tsc pebs
bts pni dtes64 monitor ds_cpl vmx cid cx16 xtpr pdcm lahf_lm tpr_shadow
bogomips	: 6018.36
clflush size	: 64
cache_alignment	: 128
address sizes	: 36 bits physical, 48 bits virtual
power management:

 
Best Regards,
Hayes


> -----Original Message-----
> From: Anand Raj Manickam [mailto:anandrm@gmail.com] 
> Sent: Tuesday, February 01, 2011 6:38 PM
> To: Francois Romieu
> Cc: Ivan Vecera; netdev@vger.kernel.org; Hayeswang
> Subject: Re: Realtek r8168C / r8169 driver VLAN TAG stripping
> 
> On Tue, Feb 1, 2011 at 3:42 PM, Francois Romieu 
> <romieu@fr.zoreil.com> wrote:
> > Ivan Vecera <ivecera@redhat.com> :
> > [...]
> >> Unfortunately I have no local access (it's placed in 
> China) or remote 
> >> serial console to the system with this 8168c. The second 
> problem is 
> >> that the system is connected to the switch that does not pass the 
> >> packets with VLAN tags -> it seems that at least Tx 
> packets have the VLAN tag.
> >>
> >> I'm sorry I'm not able to help more.
> >
> > Thanks a lot for the information, it is both welcome and helpful.
> >
> > I'll freeze Anand's report for now as "8168c + unspecified glue 
> > hardware bug with unknown product manufactured by Arkino on 
> > unidentified motherboard with unknown number of processors".
> 
>  cat /proc/cpuinfo
> processor	: 0
> vendor_id	: AuthenticAMD
> cpu family	: 16
> model		: 6
> model name	: AMD Sempron(tm) 140 Processor
> stepping	: 2
> cpu MHz		: 2700.641
> cache size	: 1024 KB
> fdiv_bug	: no
> hlt_bug		: no
> f00f_bug	: no
> coma_bug	: no
> fpu		: yes
> fpu_exception	: yes
> cpuid level	: 5
> wp		: yes
> flags		: fpu vme de pse tsc msr pae mce cx8 apic sep 
> mtrr pge mca cmov
> pat pse36 clflush mmx fxsr sse sse2 syscall nx mmxext 
> fxsr_opt pdpe1gb rdtscp lm 3dnowext 3dnow constant_tsc up 
> nonstop_tsc extd_apicid pni monitor cx16 popcnt lahf_lm svm 
> extapic cr8_legacy abm sse4a misalignsse 3dnowprefetch osvw 
> ibs skinit wdt npt lbrv svm_lock nrip_save
> bogomips	: 5401.28
> clflush size	: 64
> cache_alignment	: 64
> address sizes	: 48 bits physical, 48 bits virtual
> power management: ts ttp tm stc 100mhzsteps hwpstate
> 
> 

