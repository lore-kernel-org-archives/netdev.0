From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] InfiniBand/RDMA merge plans for 2.6.24
Date: Fri, 14 Sep 2007 09:18:01 -0700
Message-ID: <adaveadjk5i.fsf@cisco.com>
References: <adahclymos8.fsf@cisco.com>
	<46E97BB0.9030106@opengridcomputing.com> <adaps0ml18e.fsf@cisco.com>
	<1189724358.9540.113.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Steve Wise" <swise@opengridcomputing.com>,
	"netdev" <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org, anilgv@broadcom.com,
	uri@broadcom.com
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3-in.cisco.com ([171.71.176.72]:6601 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764614AbXINQSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 12:18:14 -0400
In-Reply-To: <1189724358.9540.113.camel@dell> (Michael Chan's message of "Thu, 13 Sep 2007 15:59:18 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > > I've been meaning to track down the bnx2 iscsi offload patch to look
 > > and see if this issue is addressed, since the same problem seems to
 > > exist: it seems an iscsi connection and a main stack tcp connection
 > > might share the same 4-tuple unless something is done to avoid that
 > > happening.

 > iSCSI does not do passive listens, only active connections to the
 > target.  But you're right, the port space is still shared between iSCSI
 > and the main stack.  We currently rely on user apps binding to the main
 > stack to reserve certain ephemeral ports, and telling the iSCSI driver
 > which ports to use.

Got it... I wasn't thinking that clearly, but it is clear that a full
4-tuple collision with only active connections is quite unlikely.  I
guess you would have to make both an offloaded and a non-offloaded
iSCSI connection to the same target and get really unlucky with
ephemeral port allocation.  So in practice I guess it's not an issue
at all with your driver yet.

However, do you have any plans to support iSCSI offload for targets?
Also, looking at the first CNIC patch, I can't help but notice that
you seem to have at least some support for iWARP there.  How does the
CNIC look?  Does it share the same interface/addresses as the
non-offload NIC, or does it create a completely separate netdevice?

I want to make sure that whatever solution we come up with for cxgb3
doesn't cause problems for you.  And of course if you have a better
idea than what Steve has come up with, that would be great :)

 - R.
