From: =?ISO-8859-1?Q?Ortwin_Gl=FCck?= <odi@odi.ch>
Subject: 3.14 regression: huge latency in read/select on tun
Date: Wed, 02 Apr 2014 18:17:34 +0200
Message-ID: <533C381E.9090103@odi.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fep14.mx.upcmail.net ([62.179.121.34]:39580 "EHLO
	fep14.mx.upcmail.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758808AbaDBQSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 12:18:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Since 3.14 the openconnect VPN tunnel becomes unusable for me because
packets appear on the tun device at a horribly low rate. 3.12 and 3.13
do not exhibt the problem.

Here is an strace of openconnect trying to read from its fd
  7 -> /dev/net/tun

15:07:33.130640 read(7, 0x1e05e58, 1280) = -1 EAGAIN (Resource
temporarily unavailable)
===> should return available data already
15:07:33.130745 select(8, [3 6 7], [], [6], {30, 0}) = 1 (in [7], left
{29, 783272})
===> HUGE 217ms delay here
15:07:33.347681 read(6, 0x1dfc973, 5)   = -1 EAGAIN (Resource
temporarily unavailable)
15:07:33.347806 read(7,
"E\10\5\0b\343@\0@\6\17~\n\363X\236\n\271UE\222:\0\26\37O\7\342\315\21q\33"...,
1280) = 1280


The send queue of the socket being routed via the tun device has a lot
of outstanding data (here an scp/ssh upload):
tcp        0  29788 local:46577  remote:22   ESTABLISHED

(IPs replaced for privacy)

toggling TCP autocorking has no influence.

Any ideas what could be the culprit?

Ortwin
