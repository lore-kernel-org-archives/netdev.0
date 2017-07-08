From: Marc Duponcheel <marc@offline.be>
Subject: meson-gxbb-p200 4.12.0 network TCP transfer stalls
Date: Sat, 8 Jul 2017 02:55:42 +0200
Message-ID: <20170708005542.GA20515@offline.be>
Reply-To: Marc Duponcheel <marc@offline.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marc Duponcheel <marc@offline.be>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.offline.be ([79.132.231.86]:45536 "EHLO mail.offline.be"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752639AbdGHAzT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Jul 2017 20:55:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all

Similar to 'crow'

ARM GLX Khadas VIM Pro - Ethernet detected as only 10Mbps and stalled after some traffic

I also have the situation where copying large file over LAN stalls.

3.14.29 performance is good 4.12.0 performance not

output of 'mii-tool -vvv eth0' differs (e.g. flow-control)

 --
$ echo *
3.14.29 4.12.0

$ diff */mii-tool-vvv.eth0
4,5c4,5
<     1040 79ad 001c c916 0de1 c5e1 006d 2801
<     4806 0200 3800 0000 0000 4007 0000 2000
---
>     1040 79ad 001c c916 01e1 c5e1 006f 2001
>     5806 0200 3800 0000 0000 4007 0002 2000
7c7
<     211a 0862 30ee 0002 6295 0000 0000 0000
---
>     211a 0863 302c 0002 0000 0020 0000 0000
12c12
<   advertising:  1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control
---
>   advertising:  1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
 --

When capturing with tcpdump stalled transfer shows various
retransmits, duplicate acks and fast retransmit issues.

# nstat | grep ^Tcp

also shows much more exceptions in 4.12.0 versus 3.14.29

$ cat 3.14.29/nstat^Tcp
TcpInSegs                       18                 0.0
TcpOutSegs                      11                 0.0
TcpExtTCPHPAcks                 11                 0.0

$ cat 4.12.0/nstat^Tcp
TcpPassiveOpens                 2                  0.0
TcpInSegs                       687                0.0
TcpOutSegs                      379                0.0
TcpExtDelayedACKs               4                  0.0
TcpExtTCPHPHits                 207                0.0
TcpExtTCPPureAcks               10                 0.0
TcpExtTCPHPAcks                 350                0.0
TcpExtTCPAutoCorking            6                  0.0
TcpExtTCPOrigDataSent           365                0.0


 Perhaps one must compare 3.14.29 am_realtek.c and realtek.c with 4.12.0realtek.c


 thanks
