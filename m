From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH  v2 04/13] Connection Manager
Date: Tue, 05 Dec 2006 09:14:36 -0600
Message-ID: <1165331676.16087.29.camel@stevo-desktop>
References: <20061202224917.27014.15424.stgit@dell3.ogc.int>
	 <20061202224958.27014.65970.stgit@dell3.ogc.int>
	 <20061204110825.GA26251@2ka.mipt.ru> <ada8xhnk6kv.fsf@cisco.com>
	 <20061205050725.GA26033@2ka.mipt.ru> <ada3b7uhqlk.fsf@cisco.com>
	 <20061205051657.GB26845@2ka.mipt.ru>  <aday7pmgbf6.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	openib-general@openib.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-217-226.sw.biz.rr.com ([24.153.217.226]:53578 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S968280AbWLEPOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 10:14:36 -0500
To: Roland Dreier <rdreier@cisco.com>
In-Reply-To: <aday7pmgbf6.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-12-04 at 21:27 -0800, Roland Dreier wrote:
>  > So will each new NIC implement some parts of TCP stack in theirs drivers?
> 
> I hope not.  The driver we merged (amso1100) did it completely in FW,
> with a separate MAC and IP interface for the RDMA connections.  I
> think we better understand the Chelsio driver pretty well and think it
> over carefully before we merge it.
> 

Chelsio doesn't implement TCP stack in the driver.  Just like Ammasso,
it sends messages to the HW to setup connections.  It differs from
Ammasso in at least 2 ways:

1) Ammasso does the MPA negotiations in FW/HW.  Chelsio does it in the
RDMA driver.  So there is code in the Chelsio driver to handle MPA
startup negotiation (the exchange of 2 packets over the TCP connection
while its still in streaming more).  BTW: This code _could_ be moved
into the core IWCM if we find it could be used by other rnic devices
(don't know yet).

2) Ammasso implments a 100% deep adapter.  It does ARP, routing, IP,
TCP, and IWARP protocols all in firmware/hw.  It had 2 mac addresses
simulating 2 ethernet ports.  One exclusively for RDMA connections, and
one for host stack traffic.  Chelsio implements a shallower adapter that
only does TCP in HW.  ARP, for instance, is handled by the native stack
and the rdma driver uses netevents to maintain arp tables in the HW for
use by the offloaded TCP connections.

Steve.



