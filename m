From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Why is destructor_arg in shinfo?
Date: Tue, 29 Jun 2010 16:09:13 +0200
Message-ID: <4C29FE89.8090901@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	David Miller <davem@davemloft.net>
To: Johann Baudy <johann.baudy@gnu-log.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from claw.goop.org ([74.207.240.146]:36172 "EHLO claw.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754821Ab0F2OJT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jun 2010 10:09:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm wondering why "net: TX_RING and packet mmap" (69e3c75) ended up
putting the skb destructor's arg in the skb's shinfo.  It seems like an
odd mismatch, since the skb and the shinfo have different lifetimes. 
And in principle you might have two skbs with different destructors
sharing a shinfo, and therefore conflict over the use of destructor_arg.

What's the rationale?

Would it make sense to have a shinfo destructor as well?

Thanks,
    J
