From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH Round 2 0/2][RFC] Network Event Notifier Mechanism
Date: Tue, 27 Jun 2006 13:21:32 -0700 (PDT)
Message-ID: <20060627.132132.21596632.davem@davemloft.net>
References: <1151420539.3207.29.camel@stevo-desktop>
	<20060627.131443.104035750.davem@davemloft.net>
	<1151439548.20252.2.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:8364
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030341AbWF0UVc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 16:21:32 -0400
To: swise@opengridcomputing.com
In-Reply-To: <1151439548.20252.2.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steve Wise <swise@opengridcomputing.com>
Date: Tue, 27 Jun 2006 15:19:08 -0500

> For an RDMA NIC, all this logic is in HW, which is why we need the event
> notification; to tell the HW to change its next hop information.

Back to the route change notification, I still think you can
get what you need by just looking for the route delete.

You can match if any RDMA connection is using the deleted
route, mark it "update pending" or something like that,
and when the you get the "new route" event you can walk the
"pending" list and try to relookup the route for those
connections.
