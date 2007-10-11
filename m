From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] IB/ipoib: Bound the net device to the ipoib_neigh structue
Date: Thu, 11 Oct 2007 13:17:39 -0700
Message-ID: <ada3awhcsnw.fsf@cisco.com>
References: <11916151232222-git-send-email-fubar@us.ibm.com>
	<470C200D.4010705@pobox.com> <470C2343.1020800@garzik.org>
	<20071009.181246.41634534.davem@davemloft.net> <706.1191979132@death>
	<470CF7E1.6060503@voltaire.com> <aday7eaddod.fsf@cisco.com>
	<470E37AD.3070408@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>, jeff@garzik.org,
	David Miller <davem@davemloft.net>, ogerlitz@voltaire.com,
	netdev@vger.kernel.org, Moni Levy <monil@voltaire.com>
To: Moni Shoua <monis@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3-in.cisco.com ([171.71.176.72]:6498 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755085AbXJKUTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 16:19:22 -0400
In-Reply-To: <470E37AD.3070408@voltaire.com> (Moni Shoua's message of "Thu, 11 Oct 2007 16:48:13 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > It happens only when ib interfaces are slaves of a bonding device.
 > I thought before that the stuck is in napi_disable() but it's almost right.
 > I put prints before and after call to napi_disable and see that it is called twice.
 > I'll try to investigate in this direction.
 > 
 > ib0: stopping interface
 > ib0: before napi_disable
 > ib0: after napi_disable
 > ib0: downing ib_dev
 > ib0: All sends and receives done.
 > ib0: stopping interface
 > ib0: before napi_disable

Yes, two napi_disable()s in a row without a matching napi_enable()
will deadlock.  I guess the question is why the ipoib interface is
being stopped twice.

If you just take the net-2.6.24 tree (without bonding patches), does
bonding for ethernet interfaces work OK, or is there a similar problem
with double napi_disable()?  How about bonding of ethernet after this
batch of bonding patches?

 - R.
