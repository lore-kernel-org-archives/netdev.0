From: Peter Schmitt <peter.schmitt82@yahoo.de>
Subject: PROBLEM: GRE forwarding not working with 3.10.x, WCCPv2 and Cisco 7200 Router showing IP0 bad-hlen 4 in tcpdump
Date: Wed, 16 Oct 2013 09:35:13 +0100 (BST)
Message-ID: <1381912513.57737.YahooMailNeo@web172002.mail.ir2.yahoo.com>
Reply-To: Peter Schmitt <peter.schmitt82@yahoo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm32.bullet.mail.ne1.yahoo.com ([98.138.229.25]:49018 "HELO
	nm32.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753674Ab3JPIiX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 04:38:23 -0400
References: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a setup with the current kernel (3.10.16) and can't get WCCPv2 t=
o work using GRE since kernel 3.10.x. With 3.9.x everything was working=
 fine.

My setup is simple with three boxes included:

Client (10.111.111.222/24) -- (10.111.111.1/24) Cisco 7200 (192.168.180=
=2E113/24) -- Internet Gateway
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 (192.168.234.=
1/30)
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 |
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 W=
CCPv2
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 |
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 (192.168.234.=
2/30)
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 Caching Box with Squid 2.7STABLE9 WCCPv2


On the caching box, I have the interfaces:
6: eth3 inet 192.168.234.2/30 scope global eth3\ valid_lft forever pref=
erred_lft forever
22: wccp104102 inet 192.168.234.2/32 scope global wccp104102\ valid_lft=
 forever preferred_lft forever=A0

The WCCP handshake is established and I can see messages on the Cisco R=
outer:
*Oct 14 10:44:09.487: %WCCP-5-SERVICEFOUND: Service 80 acquired on WCCP=
 client 192.168.234.2
*Oct 14 10:44:09.495: %WCCP-5-SERVICEFOUND: Service 90 acquired on WCCP=
 client 192.168.234.2

When the client now starts a request, it gets connection timeouts:
>wget google.com
--2013-10-14 13:53:30--=A0 http://google.com/
Resolving google.com (google.com)... 173.194.70.113, 173.194.70.100, 17=
3.194.70.138, ...
Connecting to google.com (google.com)|173.194.70.113|:80... failed: Con=
nection timed out.
Connecting to google.com (google.com)|173.194.70.100|:80... failed: Con=
nection timed out.
=2E..

A tcpdump on the Caching Box reveals the following:
> tcpdump -i eth3 -n proto gre=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=20
tcpdump: verbose output suppressed, use -v or -vv for full protocol dec=
ode
listening on eth3, link-type EN10MB (Ethernet), capture size 96 bytes
13:53:35.686377 IP 192.168.234.1 > 192.168.234.2: GREv0, length 68: gre=
-proto-0x883e
13:53:36.678849 IP 192.168.234.1 > 192.168.234.2: GREv0, length 68: gre=
-proto-0x883e
13:53:38.682782 IP 192.168.234.1 > 192.168.234.2: GREv0, length 68: gre=
-proto-0x883e
13:53:42.690670 IP 192.168.234.1 > 192.168.234.2: GREv0, length 68: gre=
-proto-0x883e
13:53:50.714444 IP 192.168.234.1 > 192.168.234.2: GREv0, length 68: gre=
-proto-0x883e
13:54:06.745979 IP 192.168.234.1 > 192.168.234.2: GREv0, length 68: gre=
-proto-0x883e
13:54:38.813539 IP 192.168.234.1 > 192.168.234.2: GREv0, length 68: gre=
-proto-0x883e
13:54:39.808525 IP 192.168.234.1 > 192.168.234.2: GREv0, length 68: gre=
-proto-0x883e
13:54:41.812964 IP 192.168.234.1 > 192.168.234.2: GREv0, length 68: gre=
-proto-0x883e
13:54:45.816337 IP 192.168.234.1 > 192.168.234.2: GREv0, length 68: gre=
-proto-0x883e=20

> tcpdump -i wccp104102 -n=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=20
tcpdump: verbose output suppressed, use -v or -vv for full protocol dec=
ode
listening on wccp104102, link-type LINUX_SLL (Linux cooked), capture si=
ze 96 bytes
13:53:35.686377 IP0 bad-hlen 4
13:53:36.678849 IP0 bad-hlen 4
13:53:38.682782 IP0 bad-hlen 4
13:53:42.690670 IP0 bad-hlen 4
13:53:50.714444 IP0 bad-hlen 4
13:54:06.745979 IP0 bad-hlen 4
13:54:38.813539 IP0 bad-hlen 4
13:54:39.808525 IP0 bad-hlen 4
13:54:41.812964 IP0 bad-hlen 4
13:54:45.816337 IP0 bad-hlen 4=20
So I get correct GRE packets on the eth3 interface, but only bad-hlen m=
essages from the GRE interface.


ver_linux from the Caching box:

Linux cache 3.10.16-x86 #1 SMP Mon Oct 14 06:33:21 CEST 2013 i686 GNU/L=
inux
Gnu C=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0 =A0 =A0 4.4.3
Gnu make=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 3.81
binutils=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
 2.20.1
util-linux=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 2.1=
7.2
mount=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
 2.15.1-rc1
module-init-tools=A0=A0=A0=A0=A0=A0=A0 3.11.1
e2fsprogs=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0 =A0=A0 1.42.7
PPP=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 2.4.5
Linux C Library=A0=A0=A0=A0=A0=A0=A0=A0=A0 2.11.1
Dynamic linker (ldd)=A0=A0 2.11.1
Procps=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 3.2.=
8
Net-tools=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 1.60
Kbd=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 1.15
Sh-utils=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 7.4
Modules Loaded=A0=A0=A0=A0=A0=A0 xt_TPROXY nf_tproxy_core xt_set xt_soc=
ket nf_defrag_ipv6 xt_REDIRECT ip_set_hash_ip hwmon_vid hwmon bridge ip=
_set iptable_nat nf_nat_ipv4 ipt_REJECT nf_nat_irc nf_conntrack_irc nf_=
nat_ftp nf_nat nf_conntrack_ftp ip_gre gre bonding pcspkr uhci_hcd ehci=
_pci ehci_hcd lpc_ich mfd_core pata_acpi ata_generic


Has anybody an idea of what's going wrong here? If you need any further=
 information or some pcap files, I will surely provide them.

Thanks a lot for your attention!

Best regards,
Peter
