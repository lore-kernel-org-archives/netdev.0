From: Erik Hensema <erik@hensema.net>
Subject: TCP/IPv6 broken in Linux 2.5.64?
Date: Tue, 18 Mar 2003 14:11:04 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030318131104.GA16367@hensema.net>
Reply-To: erik@hensema.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'm trying to upgrade to Linux 2.5.x from 2.4.x. It seems to be working
fine, except for IPv6: a TCP session can be established, but I can't send
data. I can receive it though.

This is a tcpdump session of me telnetting to the smtp port of my server,
with is on local ethernet; native ipv6:

14:01:24.169321 bender.ipv6.hensema.net.32926 > dexter.ipv6.hensema.net.smtp: S 3441486378:3441486378(0) win 5760 <mss 1440,sackOK,timestamp 3067201 0,nop,wscale 0>
14:01:24.169532 dexter.ipv6.hensema.net.smtp > bender.ipv6.hensema.net.32926: S 2141989668:2141989668(0) ack 3441486379 win 5712 <mss 1440,sackOK,timestamp 241707598 3067201,nop,wscale 0>
14:01:24.170104 bender.ipv6.hensema.net.32926 > dexter.ipv6.hensema.net.smtp: . ack 1 win 5760 <nop,nop,timestamp 3067202 241707598>
14:01:24.187583 dexter.ipv6.hensema.net.47911 > bender.ipv6.hensema.net.ident: S 2130642408:2130642408(0) win 5760 <mss 1440,sackOK,timestamp 241707600 0,nop,wscale 0>
14:01:24.187612 bender.ipv6.hensema.net.ident > dexter.ipv6.hensema.net.47911: R 0:0(0) ack 2130642409 win 0
14:01:24.198246 dexter.ipv6.hensema.net.smtp > bender.ipv6.hensema.net.32926: P 1:87(86) ack 1 win 5712 <nop,nop,timestamp 241707601 3067202>
14:01:24.198285 bender.ipv6.hensema.net.32926 > dexter.ipv6.hensema.net.smtp: . ack 87 win 5760 <nop,nop,timestamp 3067230 241707601>
14:01:27.397607 bender.ipv6.hensema.net.32926 > dexter.ipv6.hensema.net.smtp: P 1:7(6) ack 87 win 5760 <nop,nop,timestamp 3070430 241707601>
14:01:27.598549 bender.ipv6.hensema.net.32926 > dexter.ipv6.hensema.net.smtp: P 1:7(6) ack 87 win 5760 <nop,nop,timestamp 3070631 241707601>
14:01:28.199460 bender.ipv6.hensema.net.32926 > dexter.ipv6.hensema.net.smtp: P 1:7(6) ack 87 win 5760 <nop,nop,timestamp 3071232 241707601>
14:01:29.223402 bender.ipv6.hensema.net.32926 > dexter.ipv6.hensema.net.smtp: P 1:7(6) ack 87 win 5760 <nop,nop,timestamp 3072256 241707601>
14:01:31.015042 bender.ipv6.hensema.net.32926 > dexter.ipv6.hensema.net.smtp: P 1:7(6) ack 87 win 5760 <nop,nop,timestamp 3074048 241707601>
14:01:34.342488 bender.ipv6.hensema.net.32926 > dexter.ipv6.hensema.net.smtp: P 1:7(6) ack 87 win 5760 <nop,nop,timestamp 3077376 241707601>
14:01:40.997436 bender.ipv6.hensema.net.32926 > dexter.ipv6.hensema.net.smtp: P 1:7(6) ack 87 win 5760 <nop,nop,timestamp 3084032 241707601>
14:01:53.795498 bender.ipv6.hensema.net.32925 > dexter.ipv6.hensema.net.smtp: P 0:6(6) ack 1 win 5760 <nop,nop,timestamp 3096832 241706937>
14:01:54.051386 bender.ipv6.hensema.net.32926 > dexter.ipv6.hensema.net.smtp: P 1:7(6) ack 87 win 5760 <nop,nop,timestamp 3097088 241707601>

I do see the SMTP greeting. However, when I send a RSET, there's no response
from the server.

IPv4 is working fine. icmpv6/ipv6 and udp/ipv6 too.

bender is running linux 2.5.64. dexter is running linux 2.4.18, mostly the
SuSE 8.0 version (that is: quite heavily patched).
-- 
Erik Hensema (erik@hensema.net)
