From: Martin Lucina <mato@kotelna.sk>
Subject: Re: sky2 hangs, hw csum errors with 2.6.18
Date: Tue, 3 Oct 2006 20:21:20 +0200
Message-ID: <20061003182119.GM14180@dezo.moloch.sk>
References: <20060922112442.GB4161@dezo.moloch.sk> <20060922095642.5acf4ac9@dxpl.pdx.osdl.net> <20060922182924.GE4161@dezo.moloch.sk> <20060922113152.02874cbc@localhost.localdomain> <20060922183812.GF4161@dezo.moloch.sk> <20060922115008.5060c599@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chrocht.moloch.sk ([62.176.169.44]:35263 "EHLO mail.moloch.sk")
	by vger.kernel.org with ESMTP id S964898AbWJCSVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2006 14:21:24 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060922115008.5060c599@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

I'm still getting tx timeouts even after applying the patch you sent me
and forcing tx flow control off:

Sep 28 20:35:53 dezo kernel: NETDEV WATCHDOG: eth1: transmit timed out
Sep 28 20:35:53 dezo kernel: sky2 eth1: tx timeout
Sep 28 20:35:53 dezo kernel: sky2 eth1: transmit ring 420 .. 379 report=420 done=420
Sep 28 20:35:53 dezo kernel: sky2 hardware hung? flushing
Sep 28 20:50:28 dezo kernel: NETDEV WATCHDOG: eth1: transmit timed out
Sep 28 20:50:28 dezo kernel: sky2 eth1: tx timeout
Sep 28 20:50:28 dezo kernel: sky2 eth1: transmit ring 379 .. 338 report=420 done=420
Sep 28 20:50:28 dezo kernel: sky2 status report lost?
Sep 28 20:51:53 dezo kernel: NETDEV WATCHDOG: eth1: transmit timed out
Sep 28 20:51:53 dezo kernel: sky2 eth1: tx timeout
Sep 28 20:51:53 dezo kernel: sky2 eth1: transmit ring 420 .. 379 report=420 done=420
Sep 28 20:51:53 dezo kernel: sky2 hardware hung? flushing
Sep 28 21:08:03 dezo kernel: NETDEV WATCHDOG: eth1: transmit timed out
Sep 28 21:08:03 dezo kernel: sky2 eth1: tx timeout
Sep 28 21:08:03 dezo kernel: sky2 eth1: transmit ring 379 .. 338 report=420 done=420
Sep 28 21:08:03 dezo kernel: sky2 status report lost?
Sep 28 21:09:28 dezo kernel: NETDEV WATCHDOG: eth1: transmit timed out
Sep 28 21:09:28 dezo kernel: sky2 eth1: tx timeout
Sep 28 21:09:28 dezo kernel: sky2 eth1: transmit ring 420 .. 379 report=420 done=420
Sep 28 21:09:28 dezo kernel: sky2 hardware hung? flushing
Sep 28 21:25:18 dezo kernel: NETDEV WATCHDOG: eth1: transmit timed out
Sep 28 21:25:18 dezo kernel: sky2 eth1: tx timeout
Sep 28 21:25:18 dezo kernel: sky2 eth1: transmit ring 379 .. 338 report=420 done=420
Sep 28 21:25:18 dezo kernel: sky2 status report lost?
Sep 28 21:26:38 dezo kernel: NETDEV WATCHDOG: eth1: transmit timed out
Sep 28 21:26:38 dezo kernel: sky2 eth1: tx timeout
Sep 28 21:26:38 dezo kernel: sky2 eth1: transmit ring 420 .. 379 report=420 done=420
Sep 28 21:26:38 dezo kernel: sky2 hardware hung? flushing
Sep 28 21:41:42 dezo kernel: NETDEV WATCHDOG: eth1: transmit timed out
Sep 28 21:41:42 dezo kernel: sky2 eth1: tx timeout
Sep 28 21:41:42 dezo kernel: sky2 eth1: transmit ring 379 .. 338 report=420 done=420
Sep 28 21:41:42 dezo kernel: sky2 status report lost?
Sep 28 21:42:57 dezo kernel: NETDEV WATCHDOG: eth1: transmit timed out
Sep 28 21:42:57 dezo kernel: sky2 eth1: tx timeout
Sep 28 21:42:57 dezo kernel: sky2 eth1: transmit ring 420 .. 379 report=420 done=420
Sep 28 21:42:57 dezo kernel: sky2 hardware hung? flushing
Sep 28 21:49:19 dezo kernel: sky2 eth1: disabling interface
Sep 28 21:49:19 dezo kernel: sky2 eth1: enabling interface
Sep 28 21:49:22 dezo kernel: sky2 eth1: Link is up at 1000 Mbps, full duplex, flow control
 rx
Sep 28 21:49:30 dezo kernel: eth1: no IPv6 routers present

This appears to have resulted in a system hang some time later, since
the machine stopped responding and the last message I see in the syslog
is:

Sep 28 22:09:22 dezo -- MARK --

The box was dead when I arrived at the office the next morning.

Also, I'm seeing a bunch of messages like this (in addition to the hw
csum failures I mentioned in my original email):

Oct  2 16:42:17 dezo kernel: SKB BUG: Invalid truesize (3944) len=12745, sizeof(sk_buff)=2
32
Oct  2 16:42:29 dezo kernel: SKB BUG: Invalid truesize (3944) len=16384, sizeof(sk_buff)=2
32
Oct  2 16:42:29 dezo last message repeated 11 times
Oct  3 17:20:54 dezo kernel: SKB BUG: Invalid truesize (3944) len=16384, sizeof(sk_buff)=2
32
Oct  3 17:21:56 dezo last message repeated 4 times
Oct  3 17:21:56 dezo last message repeated 3 times
Oct  3 17:23:46 dezo last message repeated 2 times
Oct  3 20:03:28 dezo kernel: SKB BUG: Invalid truesize (3944) len=16384, sizeof(sk_buff)=2
32
Oct  3 20:03:28 dezo last message repeated 16 times

After which some open TCP sockets between dezo and another box (also
with sky2) start running really slowly.

Not sure how to proceed with this - is there a newer version of sky2
than that in 2.6.18 which I can test?

-mato
