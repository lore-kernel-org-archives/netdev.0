From: Andi Kleen <andi@firstfloor.org>
Subject: No pmtu probing on retransmits?
Date: Sun, 3 Feb 2008 13:37:19 +0100
Message-ID: <20080203123719.GA3323@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: jheffner@psc.edu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out04.alice-dsl.net ([88.44.63.6]:8079 "EHLO
	smtp-out04.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935844AbYBCMhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2008 07:37:36 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hallo,

While looking for something else in tcp_output.c I noticed that
MTU probing seems to be only done in tcp_write_xmit (when
packets come directly from process context), but not via the timer
driven timer retransmit path (tcp_retransmit_skb). Is that intentional?
It looks quite weird. I would normally assume PMTU blackholes get usually
detected on retransmit timeouts. Or do I miss something? 

You seem to have assumed interrupt context at least
because tcp_mtu_probe() uses GFP_ATOMIC which is only needed for
interrupts. Currently it is only called in process context I think.

-Andi

