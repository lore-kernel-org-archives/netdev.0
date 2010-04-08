From: David Miller <davem@davemloft.net>
Subject: dhcp client packet sniffing...
Date: Thu, 08 Apr 2010 03:50:49 -0700 (PDT)
Message-ID: <20100408.035049.177640912.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53950
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751410Ab0DHKuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 06:50:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is an old topic, but looking at traces tonight I was reminded
about it.

dhcp clients sniff every packet in the system, the reason it does this
and the things we can do to make it not have to do so have been
discussed before.  Actually, I don't remember where we got with
that and if we were able to make it such that the dhcp client
doesn't have to do this any more.  Herbert?

But, in any event, the fact of the matter is that currently it still
does on many machines.

This means every packet in the machine gets sniffed.

The DHCP client at least installs a socket filter that only accepts
the packets that the DHCP client is actually interested in.

The problem is that we clone the SKB and do some other operations
before running the socket filter.

I was thinking, what if we simply move the sk_filter() call up to
dev_queue_xmit_nit()?  And if sk_filter() rejects we don't even need
to clone the packet.
