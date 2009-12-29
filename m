From: Andreas Schuldei <schuldei@spotify.com>
Subject: ipsec performance
Date: Tue, 29 Dec 2009 22:09:19 +0100
Message-ID: <f5327b860912291309g701d6345k6517a4eb75830faf@mail.gmail.com>
Reply-To: schuldei@spotify.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:49989 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934AbZL2VJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2009 16:09:21 -0500
Received: by fxm25 with SMTP id 25so5551462fxm.21
        for <netdev@vger.kernel.org>; Tue, 29 Dec 2009 13:09:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi!

i experience performance issues with ipsec transport mode with debian
lenny and strongswan, on a stock debian kernel 2.6.26-2-amd64.

the goal is to set up a full mash of several hundred hosts, talking
ipsec with each other, in order to be able to skip firewalls and to be
able to let the hosts be spread out over several sites in a
transparent fashion.

regardless of the cipher (i tried aes and blowfish) the bandwidth
maxes out at about 0.5-0.25 of the expected (unencrypted) value,
without hitting obvious bottlenecks like cpu, disk, or ram.

tcpdump shows packages below the MTU (which is 1500):

20:25:03.313469 IP 78.31.14.86 > 78.31.14.93:
ESP(spi=0xc929dbe8,seq=0x100a87), length 1332
20:25:03.313514 IP 78.31.14.86 > 78.31.14.93:
ESP(spi=0xc929dbe8,seq=0x100a88), length 1476
20:25:03.313529 IP 78.31.14.93 > 78.31.14.86:
ESP(spi=0xc4967810,seq=0x7bcd1), length 68
20:25:03.313557 IP 78.31.14.86 > 78.31.14.93:
ESP(spi=0xc929dbe8,seq=0x100a89), length 1476
20:25:03.313603 IP 78.31.14.86 > 78.31.14.93:
ESP(spi=0xc929dbe8,seq=0x100a8a), length 1332
20:25:03.313605 IP 78.31.14.86 > 78.31.14.93:
ESP(spi=0xc929dbe8,seq=0x100a8a), length 1332
20:25:03.313606 IP 78.31.14.93 > 78.31.14.86:
ESP(spi=0xc4967810,seq=0x7bcd2), length 68
20:25:03.313649 IP 78.31.14.86 > 78.31.14.93:
ESP(spi=0xc929dbe8,seq=0x100a8b), length 1476

how can i inspect window size, fragmentation etc? are there useful
files in /proc or /sys or enlightening ip commands?

/andreas
