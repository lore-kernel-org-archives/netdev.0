From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] dccp: Auto-load (when supported) CCID plugins for
 negotiation
Date: Tue, 16 Dec 2008 13:32:00 -0800 (PST)
Message-ID: <20081216.133200.229085084.davem@davemloft.net>
References: <20081216052954.GA6199@gerrit.erg.abdn.ac.uk>
	<20081216.014045.217150811.davem@davemloft.net>
	<20081216111908.GI14518@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, mirqus@gmail.com, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60840
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751671AbYLPVb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 16:31:59 -0500
In-Reply-To: <20081216111908.GI14518@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 16 Dec 2008 09:19:08 -0200

> I guess that looking at tcp_set_congestion_control() could be a good
> start. 8-)

Certainly.

But it seems to me we are dealing with a different situation here
in DCCP.

On the TCP side we have:

1) A default congestion control module, already loaded and
   which has been selected by the admin via a sysctl setting.

2) A socket option facility to select a non-default congestion
   control algorithm to use.

These are both outside of the fast path.

Whereas the DCCP case is right in the connection creation fast path
and unconditionally executes, because it is trying to figure out what
CCID algorithms it can advertise.
