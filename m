From: Duncan Gibb <Duncan.Gibb@SiriusIT.co.uk>
Subject: Realtek 8139 max MTU
Date: Fri, 22 Aug 2008 13:33:08 +0100
Message-ID: <48AEB204.9010805@SiriusIT.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from snail.duncangibb.com ([217.169.3.184]:3954 "EHLO
	snail.duncangibb.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753219AbYHVNA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 09:00:57 -0400
Received: from outbound-masq.weybridge.siriusit.co.uk ([217.207.197.142] helo=[192.168.1.52])
	by snail.duncangibb.com with esmtpsa (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <Duncan.Gibb@SiriusIT.co.uk>)
	id 1KWVpF-00015Q-JJ
	for netdev@vger.kernel.org; Fri, 22 Aug 2008 13:33:10 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

Question for someone who knows the 8139cp driver...

Looking for a workaround for some other issues, I've felt the need to
raise the MTU on some RealTek 8139C+ network cards above 1500 bytes.  On
a stock Debian 2.6.24-etchnhalf.1-686 kernel, however, MTUs higher than
1500 (or more reasonably below 68) give SIOCSIFMTU: Invalid argument.

I can't use a different NIC because the chips are hardwired to the
devices I want to talk to.  The cards are

  http://www.traverse.com.au/productview.php?product_id=115

01:08.0 0200: 10ec:8139 (rev 20)
        Subsystem: 10ec:8139
        Flags: bus master, medium devsel, latency 64, IRQ 31
        I/O ports at 2000 [size=256]
        Memory at fe7f0000 (32-bit, non-prefetchable) [size=256]
        Capabilities: [50] Power Management version 2

I'm driving them with the 8139cp module.  8139too works as well (with
the same limitations), but logs a recommendation to use 8139cp.

I've read net/dev/core.c, drivers/net/8139too.c and drivers/net/8139cp.c
but, not being a kernel hacker or a low-level network person, don't know
where the 1500-byte limit is imposed.  8139cp defines CP_MAX_MTU as
4096, but the cp_change_mtu hook function in which that would be used is
inside an "#ifdef BROKEN" (drivers/net/8139cp.c lines 1248 to 1281 and
1948).

Can someone give me some pointers wrt what the hardware can really do
and where in the drivers/tools I should look to make it happen?

Better still, does anyone remember why the above code is in an "#ifdef
BROKEN" and what needs to be fixed?


Cheers


Duncan

-- 
Duncan Gibb, Technical Architect
Sirius Corporation - The Open Source Experts
http://www.siriusit.co.uk/
Tel: +44 870 608 0063 || +44 7977 441 515
