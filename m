From: David Miller <davem@davemloft.net>
Subject: Re: linux-2.6.22-rc1-g7b104bcb build #254 failed in tcp_yeah.c
Date: Thu, 17 May 2007 00:08:23 -0700 (PDT)
Message-ID: <20070517.000823.130237470.davem@davemloft.net>
References: <200705162218.47122.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: toralf.foerster@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46839
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754880AbXEQHIW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2007 03:08:22 -0400
In-Reply-To: <200705162218.47122.toralf.foerster@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Toralf F=F6rster <toralf.foerster@gmx.de>
Date: Wed, 16 May 2007 22:18:44 +0200

> net/built-in.o: In function `tcp_yeah_init':
> tcp_yeah.c:(.text+0x526f8): undefined reference to `tcp_vegas_init'
> net/built-in.o: In function `tcp_yeah_pkts_acked':
> tcp_yeah.c:(.text+0x52756): undefined reference to `tcp_vegas_pkts_ac=
ked'
> net/built-in.o:(.data+0x96a0): undefined reference to `tcp_vegas_stat=
e'
> net/built-in.o:(.data+0x96a4): undefined reference to `tcp_vegas_cwnd=
_event'
> net/built-in.o:(.data+0x96b0): undefined reference to `tcp_vegas_get_=
info'
> make: *** [.tmp_vmlinux1] Error 1

Thanks for the report, I'll fix it like this:

commit 44c297027bdfa6b5530b011abbb60d9e728d46ed
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Thu May 17 00:07:47 2007 -0700

    [TCP]: TCP_CONG_YEAH requires TCP_CONG_VEGAS
   =20
    These two congestion control modules share code.
   =20
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index c68196c..719c104 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -577,6 +577,7 @@ config TCP_CONG_VENO
 config TCP_CONG_YEAH
 	tristate "YeAH TCP"
 	depends on EXPERIMENTAL
+	select TCP_CONG_VEGAS
 	default n
 	---help---
 	YeAH-TCP is a sender-side high-speed enabled TCP congestion control
