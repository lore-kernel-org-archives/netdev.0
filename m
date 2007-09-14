From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9 Rev3] Implement batching skb API and support in
 IPoIB
Date: Fri, 14 Sep 2007 10:24:35 -0700 (PDT)
Message-ID: <20070914.102435.41643750.davem@davemloft.net>
References: <20070826.190420.41652839.davem@davemloft.net>
	<1188257019.4250.55.camel@localhost>
	<20070914032055.8f96449b.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, jheffner@psc.edu, rick.jones2@hp.com,
	krkumar2@in.ibm.com, gaagaan@gmail.com,
	general@lists.openfabrics.org, herbert@gondor.apana.org.au,
	jagana@us.ibm.com, jeff@garzik.org, johnpol@2ka.mipt.ru,
	kaber@trash.net, mcarlson@broadcom.com, mchan@broadcom.com,
	netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	rdreier@cisco.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: billfink@mindspring.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:45588
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752643AbXINRZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 13:25:53 -0400
In-Reply-To: <20070914032055.8f96449b.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bill Fink <billfink@mindspring.com>
Date: Fri, 14 Sep 2007 03:20:55 -0400

> TSO disabled performance is always better than equivalent TSO enabled
> performance.  With TSO enabled, the optimum performance is indeed at
> a TX/RX interrupt coalescing value of 75 usec.  With TSO disabled,
> performance is the full 10-GigE line rate of 9910 Mbps for any value
> of TX/RX interrupt coalescing from 15 usec to 105 usec.

Note that the systems where the coalescing tweaking if often necessary
are the heavily NUMA'd systems where cpu to device latency can be
huge, like the big SGI ones which is where we had to tweak things in
the tg3 driver in the first place.

On most systems, as you saw mostly in the non-TSO case, the
value choosen for the most part is arbitrary and not critical.
