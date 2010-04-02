From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Receive steering and hash and cache misses
Date: Fri, 2 Apr 2010 10:26:50 -0700
Message-ID: <20100402102650.5bdb5b52@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43013 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755789Ab0DBR1M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Apr 2010 13:27:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although Receive Packet Steering can use a hardware generated receive hash
the device driver still causes an unnecessary cache miss on the interrupt
processing CPU.  The current Ethernet network device driver receive processing
has the device driver calling eth_type_trans() which causes a the
interrupt CPU to read the received frame header.

Is there some way the hardware receive hash value could be used to
steer to the receive CPU, then have the receive CPU find the Ethernet
type field (eth_type_trans)?
