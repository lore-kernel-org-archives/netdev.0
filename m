From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCHv2 NEXT 1/1] netxen: add vlan accel support
Date: Fri, 5 Aug 2011 05:12:37 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80FE464EF82@MNEXMB2.qlogic.org>
References: <1312536015-21719-1-git-send-email-amit.salecha@qlogic.com>
	<1312536015-21719-2-git-send-email-amit.salecha@qlogic.com>
 <20110805.024247.1468547132343070339.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe005.messaging.microsoft.com ([213.199.154.143]:18129
	"EHLO DB3EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752839Ab1HEKMw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Aug 2011 06:12:52 -0400
In-Reply-To: <20110805.024247.1468547132343070339.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller [mailto:davem@davemloft.net]
> Subject: Re: [PATCHv2 NEXT 1/1] netxen: add vlan accel support
> 
> From: <amit.salecha@qlogic.com>
> Date: Fri, 5 Aug 2011 02:20:15 -0700
> 
> > From: Rajesh K Borundia <rajesh.borundia@qlogic.com>
> >
> > o This increases performance on vlan interface.
> > o In case of fw reset, need to reprogram the ip addresses.
> > o Support LRO on vlan interface.
> >
> > Signed-off-by: Rajesh K Borundia <rajesh.borundia@qlogic.com>
> > Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
> 
> As far as I can tell your card doesn't accelerate VLANs in hardware
> at all, is this true?
> 
True.

> I think it's very cumbersome and it doesn't make sense for every
> driver in your situation to add this same sequence of software calls.
> 
> Some generic facility and interfaces should be created so that the
> code doing this software VLAN acceleration is consolidated into
> one place and any driver can follow a simple to use API in order
> to make use of it.

Basically netxen_nic LRO requirement is to program ip addresses in HW.
After fw recovery we don't get vlan devices by any kernel api, so we are adding NETIF_VLAN_ACC support.
Earlier kernel had vlan group support, through that we get vlan devices and then their ip addresses.

So please suggest from below option:
   1) We can add kernel api to get vlan devices belongs to base interface
   2) we can maintain linked list of ip addresses belongs to vlan device in driver.
   3) Have same patch and write kernel api for vlan acceleration code.

-Amit

