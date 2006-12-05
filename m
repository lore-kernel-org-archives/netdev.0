From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH  v2 04/13] Connection Manager
Date: Tue, 5 Dec 2006 18:27:36 +0300
Message-ID: <20061205152736.GA2274@2ka.mipt.ru>
References: <20061202224917.27014.15424.stgit@dell3.ogc.int> <20061202224958.27014.65970.stgit@dell3.ogc.int> <20061204110825.GA26251@2ka.mipt.ru> <ada8xhnk6kv.fsf@cisco.com> <20061205050725.GA26033@2ka.mipt.ru> <ada3b7uhqlk.fsf@cisco.com> <20061205051657.GB26845@2ka.mipt.ru> <aday7pmgbf6.fsf@cisco.com> <1165331676.16087.29.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	openib-general@openib.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:60969 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968269AbWLEP1q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 10:27:46 -0500
To: Steve Wise <swise@opengridcomputing.com>
Content-Disposition: inline
In-Reply-To: <1165331676.16087.29.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 05, 2006 at 09:14:36AM -0600, Steve Wise (swise@opengridcomputing.com) wrote:
> Chelsio doesn't implement TCP stack in the driver.  Just like Ammasso,
> it sends messages to the HW to setup connections.  It differs from
> Ammasso in at least 2 ways:
> 
> 1) Ammasso does the MPA negotiations in FW/HW.  Chelsio does it in the
> RDMA driver.  So there is code in the Chelsio driver to handle MPA
> startup negotiation (the exchange of 2 packets over the TCP connection
> while its still in streaming more).  BTW: This code _could_ be moved
> into the core IWCM if we find it could be used by other rnic devices
> (don't know yet).
> 
> 2) Ammasso implments a 100% deep adapter.  It does ARP, routing, IP,
> TCP, and IWARP protocols all in firmware/hw.  It had 2 mac addresses
> simulating 2 ethernet ports.  One exclusively for RDMA connections, and
> one for host stack traffic.  Chelsio implements a shallower adapter that
> only does TCP in HW.  ARP, for instance, is handled by the native stack
> and the rdma driver uses netevents to maintain arp tables in the HW for
> use by the offloaded TCP connections.

So breifly saying - there is TCP stack implementation (including ARP and
routing and other parts) in hardware/firmware/driver which is guaranteed
to not be visible to host other than in form of high-level dataflow.
Am I right here?

> Steve.
> 
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
	Evgeniy Polyakov
