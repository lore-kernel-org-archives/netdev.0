From: Knut Petersen <Knut_Petersen@t-online.de>
Subject: Re: [BUG] sky2 broken for Yukon PCI-E Gigabit Ethernet Controller
 11ab:4362 (rev 19)
Date: Mon, 23 Jan 2006 20:20:09 +0100
Message-ID: <43D52C69.5090707@t-online.de>
References: <43D1C99E.2000506@t-online.de> <20060123101538.14d21bf4@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964902AbWAWTUR@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060123101538.14d21bf4@dxpl.pdx.osdl.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

>O
> =20
>
>>It seems that the SuSE Firewall locked something ....
>>
>>I started with kernel 2.6.15-git7, tried 2.6.15.1 and 2.6.16-rc1*.
>>At the moment I do use a kernel 2.6.15-git7 patched with an updated s=
ky2=20
>>(v.013).
>>I could not find a single working sky2 configuration.
>>
>>   =20
>>
>
>Are you using the full kernel.org kernel, or are you putting sky2 driv=
er into
>the SUSE kernel?
>
No SuSE kernels here. I started with kernel.org kernel 2.6.15-git7 and
had those problems. Then I tried 2.6.16-rc3-git3, the most recent kerne=
l
at the time of my original writing. As I had some other problems with
that kernel I had a look at the git tree of Linus and applied all sky2=20
related
patches to the otherwise unchanged 2.6.15-git7. 2.6.15.1 also was no
solution as sky2 seems to be not available there.

> There are a number of bug fixes related to hardware checksumming
>that are in the kernel.org kernel (2.6.15 or later).  There was one in=
 ICMP.
>These fixes relate to places in the code where a protocol decides to t=
rim a
>packet by removing bytes. I am not familiar with the SuSE Firewall. Is=
 it just
>standard netfilter modules or additional code?
> =20
>
I have to admit that I don=B4t know enough about the network layers
of the kernel, so here is a list of the network modules loaded (sky2
compiled into the kernel). SuSEFirewall is just standard netfiltering
using those modules.

ipt_MASQUERADE          3968  1
pppoe                  15360  2
pppox                   4616  1 pppoe
af_packet              23240  2
ppp_generic            30740  6 pppoe,pppox
slhc                    7040  1 ppp_generic
ipt_TOS                 2816  28
ipt_TCPMSS              4800  2
ipt_LOG                 7232  77
ipt_limit               2880  77
ipt_pkttype             1984  2
ipt_state               2240  45
ip6t_REJECT             5824  3
ipt_REJECT              5952  3
iptable_mangle          3200  1
iptable_nat             8836  1
iptable_filter          3264  1
ip6table_mangle         2752  0
ip_nat_ftp              3776  0
ip_nat                 18284  3 ipt_MASQUERADE,iptable_nat,ip_nat_ftp
ip_conntrack_ftp        8240  1 ip_nat_ftp
ip_conntrack           51020  6=20
ipt_MASQUERADE,ipt_state,iptable_nat,ip_nat_ftp,ip_nat,ip_conntrack_ftp
ip_tables              24088  11=20
ipt_MASQUERADE,ipt_TOS,ipt_TCPMSS,ipt_LOG,ipt_limit,ipt_pkttype,ipt_sta=
te,ipt_REJECT,iptable_mangle,iptable_nat,iptable_filter
ip6table_filter         3136  1
ip6_tables             25624  3 ip6t_REJECT,ip6table_mangle,ip6table_fi=
lter
ipv6                  271712  14 ip6t_REJECT

As said before, rtl8139 does work perfectly well, the same is true
for an identical system with a Via Rhine adapter.


cu,
 Knut
