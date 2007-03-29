From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] quick help with bonding?
Date: Thu, 29 Mar 2007 09:24:00 -0700
Message-ID: <22707.1175185440@death>
References: <460BE5F0.7070606@nortel.com>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: "Chris Friesen" <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:37816 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933069AbXC2QYG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 12:24:06 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2TGO4RJ022454
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2007 12:24:04 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2TGO3B6245950
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2007 12:24:03 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2TGO3fT010730
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2007 12:24:03 -0400
In-reply-to: <460BE5F0.7070606@nortel.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Friesen <cfriesen@nortel.com> wrote:

>Could someone either point me to the bonding high level design document 
>(couldn't find one at the sourceforge project page) or else give me a 
>quick overview of the code path followed by an incoming packet when 
>bonding is involved?

	There really isn't a high level design document.

	The input path goes from the driver, which (probably) calls
netif_receive_skb.  That function does its processing whatnot, the only
special step for bonding is the processing done by skb_bond() which
assigns the packet to the bonding device.  In the current mainline,
skb_bond() also does some stuff to drop traffic on inactive slaves as
the like.

	After that, the packet follows the regular input path in
netif_skb_receive.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
