From: David Miller <davem@davemloft.net>
Subject: IGB handling of zero length checksumming?
Date: Sun, 11 Apr 2010 02:40:27 -0700 (PDT)
Message-ID: <20100411.024027.120459168.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, alexander.h.duyck@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33593
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751577Ab0DKJkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 05:40:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If the IGB is given a "skb->ip_summed === CHECKSUM_PARTIAL" packet and
the data area past the TCP header is of zero length, will it do the
right thing?

I'm asking because I made a change recently in net-2.6 that causes TCP
packets with no data (ACKs, etc.) to start using CHECKSUM_PARTIAL.

And a user with IGB interfaces on a system running net-2.6 is getting
failures connecting to SSH and stuff like that and it is known that
this TCP commit of mine is the culprit.  See:

http://marc.info/?l=linux-netdev&m=127097744616962&w=2

I'm very likely to just revert this change regardless of what the
problem is, and try to sort this out in net-next-2.6, but it'd be nice
to know if IGB indeed has a problem in this area and that's the true
cause of the issue.

Thanks!
