From: Simon Horman <horms@verge.net.au>
Subject: noqueue on bonding devices
Date: Wed, 28 Jul 2010 17:32:17 +0900
Message-ID: <20100728083217.GB20227@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:37715 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752428Ab0G1IcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jul 2010 04:32:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay, Hi All,

I would just to wonder out loud if it is intentional that bonding
devices default to noqueue, whereas for instance ethernet devices
default to a pfifo_fast with qlen 1000.

The reason that I ask, is that when setting up some bandwidth
control using tc I encountered some strange behaviour which
I eventually tracked down to the queue-length of the qdiscs being 1p -
inherited from noqueue, as opposed to 1000p which would occur
on an ethernet device.

Its trivial to work around, by either altering the txqueuelen on
the bonding device before adding the qdisc or by manually setting
the qlen of the qdisc. But it did take us a while to determine the
cause of the problem we were seeing. And as it seems inconsistent
I'm interested to know why this is the case.

On an unrelated note, MAINTANERS lists bonding-devel@lists.sourceforge.net
but the (recent) archives seem to be entirely spam.  Is the MAINTAINERS
file correct?

