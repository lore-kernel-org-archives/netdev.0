From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bonding: bug in balance-alb mode (incorrect update-ARP-replies)
Date: Wed, 24 Jan 2007 17:27:57 -0800
Message-ID: <200701250127.l0P1Rv22002309@death.nxdomain.ibm.com>
References: <FA8270F9F8D35946ADDBC0F36E6667CE0175C9B8@nts27.saarstahl.de>
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
To: "JUNG, Christian" <christian.jung@saarstahl.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:53071 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965087AbXAYB2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 20:28:01 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id l0OFQLlq024835
	for <netdev@vger.kernel.org>; Wed, 24 Jan 2007 10:26:21 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0P1RwTQ529680
	for <netdev@vger.kernel.org>; Wed, 24 Jan 2007 18:27:58 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0P1Rwq4021020
	for <netdev@vger.kernel.org>; Wed, 24 Jan 2007 18:27:58 -0700
In-reply-to: <FA8270F9F8D35946ADDBC0F36E6667CE0175C9B8@nts27.saarstahl.de> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

JUNG, Christian <christian.jung@saarstahl.com> wrote:

>    You have to setup a box with at least two NICs, a bonding device
>enslaving
>    those, assign at least two IPs to the bond and make some traffic from a
>    different machine to one of those IPs.
>
>    If you delete that IP, the box will regardlessly send ARP-replies to the
>    machine which communicated to that IP before removing it.

	I've fooled around with this for a while today, and I see
generically what you're describing: after a local IP address is removed,
the corresponding entries in the bonding receive balance hash table are
not removed.  However, I'm not able induce the ill effects you describe
from this (following the script you supplied); I don't see the
(apparently) unsolicited ARP replies you show in your tcpdump traces.

	I do see some other weirdness when the receive balance hash
table becomes heavily populated, but nothing that is an ARP reply for an
address not assigned to the system.

	Is your test occuring on an isolated network, and is there other
concurrent network traffic that might be affecting things?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
