From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Fri, 22 Aug 2008 17:40:32 -0700 (PDT)
Message-ID: <20080822.174032.117057862.davem@davemloft.net>
References: <1219415417.4672.79.camel@localhost>
	<20080822221913.GA2981@ami.dom.local>
	<5f2db9d90808221701t4c576282m34a46999b76b6e83@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, hadi@cyberus.ca, jeffrey.t.kirsher@intel.com,
	jeff@garzik.org, netdev@vger.kernel.org,
	alexander.h.duyck@intel.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41288
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751432AbYHWAkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 20:40:42 -0400
In-Reply-To: <5f2db9d90808221701t4c576282m34a46999b76b6e83@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Alexander Duyck" <alexander.duyck@gmail.com>
Date: Fri, 22 Aug 2008 17:01:50 -0700

> I am almost certain that David's approach using the hash will show
> better performance than the multiqueue prio qdisc would.  The
> multiqueue prio qdisc is meant to allow for classification of traffic
> into separate traffic classes to support stuff like Enhanced Ethernet
> for Data Center (EEDC) / Data Center Bridging (DCB).

The only sensible way to implement this is to use the existing
classifier technology in the packet scheduler to choose traffic,
and then writing a TC actions or ematch module that sets the
TX queue of the SKB based upon the classification result.

The thing that was there before was very narrow in scope and
we'll just have to keep adding more special purpose modules
as more such uses come up.

With the classifiers, it's generic and any scheme can be implemented
by simply issuing different 'tc' commands.
