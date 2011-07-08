From: Bill F <falcigno@juno.com>
Subject: trying to set skb->tstamp before =?utf-8?b?bmV0aWZfcng=?= did not work in tun/tap driver, 2.6.27
Date: Fri, 8 Jul 2011 02:33:59 +0000 (UTC)
Message-ID: <loom.20110708T042440-631@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:33103 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750757Ab1GHCkL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2011 22:40:11 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Qf0z8-0005tn-Fb
	for netdev@vger.kernel.org; Fri, 08 Jul 2011 04:40:06 +0200
Received: from pool-173-73-26-13.washdc.fios.verizon.net ([173.73.26.13])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2011 04:40:06 +0200
Received: from falcigno by pool-173-73-26-13.washdc.fios.verizon.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2011 04:40:06 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
 
I am trying to set the receive timestamp for a packet in the tun/tap device
driver before sending it into the network stack (by calling netif_rx_ni). On the 
application side I'm using recvmsg() to receive the timestamp along with the 
received packet.
 
I expected that any non-zero skb->tstamp I set would be the value my 
application would see when it used recvmsg(), but a corrupted value is 
coming out.
* If I hardcode skb->tstamp.tv64 to x7777777766666666 
        then recvmsg() always gets x011afd371a82fcc0.
* If I hardcode x4de684b100000000, 
        then recvmsg always gets x4f5f96640f2d1608.
* If I set a timestamp that a different process gave to the tun/tap driver
        (this is the goal), then recvmsg gets a corrupted version of that 
        timestamp.
* If I hardcode a zero tstamp, 
        then an accurate timestamp comes out (but not precise enough for my 
        project).
 
The kernel build is 2.6.27.7, the architecture is MIPS, 64bit. Shouldn't this 
work? Do I need to apply any known patches?
 
This arrangement worked last month in a similar setup: an e1000 driver 
setting tstamp before calling netif_receive_skb() in a 2.6.24 kernel and a 
686 architecture, 32 bit.
 
Thanks in advance.
Bill

