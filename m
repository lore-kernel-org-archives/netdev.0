From: David Oostdyk <daveo@ll.mit.edu>
Subject: defxx: skb_push() failing?
Date: Tue, 26 Mar 2013 10:29:34 -0400
Message-ID: <5151B0CE.5000000@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <macro@linux-mips.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:46265 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759793Ab3CZO3p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 10:29:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

In dfx_xmt_queue_pkt() in defxx.c, there is a skb_push(3) call which 
makes room for 3 packet request header bytes.  There is some discussion 
in the driver explaining why those three bytes will be available.  I 
have an old FDDI card that I'm trying to bring up:

05:05.0 FDDI network controller: Digital Equipment Corporation 
PCI-to-PDQ Interface Chip [PFI] (rev 02)

Most skbuffs that come through dfx_xmit_queue_pkt() have 11 bytes 
between skb->head and skb->data.  On the other hand, at almost exactly 
60-second intervals, an skb arrives that has zero bytes between 
skb->head and skb->data.  This normally causes a kernel panic, and for 
the time I just skip over such skb's.

Does anyone have advice on where I should start digging to find the 
cause of this?

Thanks in advance!
- David Oostdyk
