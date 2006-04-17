From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 6402] New: KERNEL 2.6.16-rX (Gentoo) && PPPD
 && SNAT
Date: Mon, 17 Apr 2006 15:27:24 -0700
Message-ID: <20060417152724.0d7321aa.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: slavon@bigtelecom.ru,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15066 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751327AbWDQW2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2006 18:28:18 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Mon, 17 Apr 2006 14:57:03 -0700
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 6402] New: KERNEL 2.6.16-rX (Gentoo) && PPPD && SNAT


http://bugzilla.kernel.org/show_bug.cgi?id=6402

           Summary: KERNEL 2.6.16-rX (Gentoo) && PPPD && SNAT
    Kernel Version: 2.6.16.ALL
            Status: NEW
          Severity: high
             Owner: shemminger@osdl.org
         Submitter: slavon@bigtelecom.ru


After start download file its stop after 4-10 mb and network is down.

Interface ppp0 is UP.
No new dmeseg or debug of syslog

try to ping ppp client:

slavon ~ # ping 192.168.0.2
PING 192.168.0.2 (192.168.0.2) 56(84) bytes of data.
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available

#ifconfig ppp0
ppp0      Link encap:Point-to-Point Protocol
          inet addr:192.168.0.1  P-t-P:192.168.0.2  Mask:255.255.255.255
          UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1396  Metric:1
          RX packets:1648 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2407 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:3
          RX bytes:75765 (73.9 Kb)  TX bytes:3242633 (3.0 Mb)

#iptables-save
*nat
:PREROUTING ACCEPT [6826:411515]
:POSTROUTING ACCEPT [11117:531811]
:OUTPUT ACCEPT [11118:531895]
-A POSTROUTING -s 192.168.0.0/255.255.255.0 -j SNAT --to-source XXX.XXX.XXX.XXX
COMMIT

slavon ~ # pppd --version
pppd version 2.4.3

slavon ~ # pptpd --version
pptpd v1.3.1

I try it in 3 Computers 2 - x86 and 1 - x86-64 - All have this trouble

its gentoo patches for kernel

 * Applying 1000_linux-2.6.16.1.patch (-p0+) 
 * Applying 1001_linux-2.6.16.2.patch (-p0+) 
 * Applying 1002_linux-2.6.16.3.patch (-p0+) 
 * Applying 1003_linux-2.6.16.4.patch (-p0+) 
 * Applying 1700_sparc-obp64-naming.patch (-p0+) 
 * Applying 1705_sparc-U1-hme-lockup.patch (-p0+) 
 * Applying 1710_sparc-sparsemem.patch (-p0+) 
 * Applying 1715_ppc32-crosscc-ssp.patch (-p0+) 
 * Applying 2400_sky2-1.1.patch (-p0+) 
 * Applying 2405_skge-1.5.patch (-p0+) 
 * Applying 2600_input-mod-devicetable.patch (-p0+) 
 * Applying 4000_deprecate-sk98lin.patch (-p0+) 
 * Applying 4100_libata-enable-atapi.patch (-p0+) 
 * Applying 4105_dm-bbr.patch (-p0+) 
 * Applying 4110_promise-pdc2037x.patch (-p0+) 
 * Applying 4200_fbsplash-0.9.2-r5.patch (-p0+) 
 * Applying 4205_vesafb-tng-1.0-rc1-r3.patch (-p0+) 
 * Applying 4300_squashfs-3.0.patch (-p0+) 
 * Applying 4400_speakup-20060103.patch (-p0+) 
 * Applying 4401_speakup-highlight-tracking-amd64.patch (-p0+) 
 * Applying 4405_alpha-sysctl-uac.patch (-p0+) 


!! In 2.6.15 kernel ALL WORK.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
