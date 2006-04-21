From: Andrew Morton <akpm@osdl.org>
Subject: Fw: Bug: PPP dropouts in >=2.6.16
Date: Fri, 21 Apr 2006 01:08:09 -0700
Message-ID: <20060421010809.6c3cfc34.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Nuri Jawad <lkml@jawad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:46268 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932190AbWDUIJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 04:09:08 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


We do seem to have had a few reports of ppp regressions around this
timeframe.


Begin forwarded message:

Date: Thu, 20 Apr 2006 23:28:24 +0200 (CEST)
From: Nuri Jawad <lkml@jawad.org>
To: linux-kernel@vger.kernel.org
Subject: Bug: PPP dropouts in >=2.6.16


Good evening,

I've recently had problems with my ADSL connection (PPPoE) after upgrading
from 2.6.15.3 to 2.6.16.5. Every now and then, it would stall for 30-50
seconds. According to tcpdump, during these dropouts packets get received
through ppp0 but none that are supposed to be sent appear on the
interface. This is consistent with the modem not sending out any data via
its ATM interface during these periods. I made sure the ISP, modem or
ethernet interface wasn't the problem with a second box running IPCop
(minimal 2.4 router distro, I can log in twice with my ISP) and a telnet
connection to the modem that never stalled.

Upgrading pppd from 2.4.2 to 2.4.4b1 and rp-pppoe from 3.5 (latest Debian
package) to 3.8 had no effect.
I was using Bittorrent and also the folding@home client so the system had
a high load. Stopping those seemed to reduce the frequency of dropouts
but they were still coming up at least every few hours. A fallback to the
old kernel made the problem disappear.

I then tested 24 hours a day this week by pinging my box from 2 hosts and
making sure above load was persistent, while trying different kernels. So
far I can say that:

- <= 2.6.15.7 is not affected, tested with .3, .4 and .7
- >= 2.6.16 is affected, tested with 2.6.16, .1, .5 and .9
- the dropouts last between 30 and 50 seconds but often exactly 41, they
  appear about every half to one hour
- a night yields 20-40 lost packets with 2.6.15 and 700-1100 with 2.6.16
  on my connection

The system:
P4 Northwood with HT enabled, 2 GB RAM, Asus P4C800
Boot/root PATA ICH5, torrents saved to SATA HD through ata-piix
Third drive through sata-promise
Debian GNU/Linux unstable
Kernel config: http://jawad.org/.config

Let me know what I can do to give you more specific information.

Regards,
Nuri
-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
