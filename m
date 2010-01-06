From: David Miller <davem@davemloft.net>
Subject: BSD 4.2 style TCP keepalives
Date: Tue, 05 Jan 2010 16:39:11 -0800 (PST)
Message-ID: <20100105.163911.10233438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, ilpo.jarvinen@helsinki.fi
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59752
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752434Ab0AFAjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 19:39:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


To make a long story short, there are still some Windows 2000
machines out there emitting BSD 4.2 style keepalives (one garbage
byte instead of an empty out-of-window probe frame).

We don't ACK these because of how tcp_sequence() sees ->end_seq
as being equal to ->rcv_wup

But we can't change tcp_sequence() to reject these frames, because if
we do then we end up mishandling connection attempts (SYN, SYN+ACK)
and retransmits of such.

Neil has shown me a patch that does a by-hand special case of this
one-garbage-byte keepalive inside of tcp_rcv_established().

Anyone have suggestions for an alternative and perhaps cleaner
implementation of a fix?

Thanks!
