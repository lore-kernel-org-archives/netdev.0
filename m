From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Wed, 12 Nov 2008 10:36:33 +0100
Message-ID: <1226482593.6834.43.camel@localhost.localdomain>
References: <1225809909.10206.90.camel@localhost.localdomain>
	 <4919DAB4.7050009@krogh.cc> <20081111.155041.90523159.davem@davemloft.net>
	 <20081111.161849.251632080.davem@davemloft.net>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jesper@krogh.cc, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:47450 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844AbYKLJgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 04:36:44 -0500
In-Reply-To: <20081111.161849.251632080.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi DaveM

Before trying out the patch, I'll give you a small status on my
progress.

When using Sun's "nxge" driver everything works.  Although this driver
is quite slow because it does not use the new TX qdisc scheme.  I hacked
net/core/dev.c to avoid the qdisc TX code-path, and got an amazing
speedup, as I now can route 930 kpps (packets per sec).

I played a bit with the msglvl (debug log level) via:
  ethtool -s eth2 msglvl 0x587

Enabling:
 NETIF_MSG_TX_ERR
 NETIF_MSG_TX_QUEUED
 NETIF_MSG_TX_DONE

The thing I noticed is that it looks like the function niu_tx_work() is
never called... (it contains a niudbg(TX_DONE, ...))

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
