From: David Miller <davem@davemloft.net>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Wed, 10 Jun 2009 05:01:22 -0700 (PDT)
Message-ID: <20090610.050122.261415364.davem@davemloft.net>
References: <adaski83ciy.fsf@cisco.com>
	<20090609.221209.07018418.davem@davemloft.net>
	<15ddcffd0906100318u2a61b7d8g991fe52439e07928@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, cl@linux-foundation.org, netdev@vger.kernel.org,
	yosefe@voltaire.com
To: or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56663
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751505AbZFJMBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 08:01:20 -0400
In-Reply-To: <15ddcffd0906100318u2a61b7d8g991fe52439e07928@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <or.gerlitz@gmail.com>
Date: Wed, 10 Jun 2009 13:18:29 +0300

> If there's no app level flow control around, UDP senders will just
> send...  so for --unicast-- the same problem of injecting tons of
> packets which can get dropped will come into play under both
> Ethernet and IB, so the user is limited by the socket buffer len and
> the neigh unres_qlen systcl.

But this generally does not cause problems via ARP, why might that
be?  Because resolution is 1) rare 2) quick.  Both of which do not
apply to this IPoIB case.

> Why not apply a similar systcl mechanism for the IB/mcast case so
> the ipoib driver level (under the user directive) will have control
> on how many packets would be queued before starting to drop.

Sure, but that's just pushing the problem around instead of
solving it.
