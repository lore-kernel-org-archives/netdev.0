From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCHv1 3/4] netxen: added sanity check for pci map
Date: Fri, 26 Mar 2010 05:40:39 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80CFEFED51E@MNEXMB2.qlogic.org>
References: <1269500806-15383-1-git-send-email-amit.salecha@qlogic.com>
	<1269500806-15383-4-git-send-email-amit.salecha@qlogic.com>
 <20100325.120446.98057142.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:18868 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750792Ab0CZKko convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 06:40:44 -0400
In-Reply-To: <20100325.120446.98057142.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, 
	Sorry for inconvenience caused. I'll take care in future work.
	I have submitted reworked patches.

-Amit 

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Friday, March 26, 2010 12:35 AM
To: Amit Salecha
Cc: netdev@vger.kernel.org; Ameen Rahman
Subject: Re: [PATCHv1 3/4] netxen: added sanity check for pci map

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Thu, 25 Mar 2010 00:06:45 -0700

> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
> 
> Return value of ioremap is not checked, NULL check added.

You're not even thinking when you make these changes.

Let's try again ok?

These ioremap() calls store the pointers into local variables.
So it doesn't work at all to just jump to err_out to clean
them up and iounmap them.

The unamp code you end up calling in netxen_pci_map() only does an
iounmap() on pointers stored in the netxen_adapter struct.  At this
point they haven't been stored there yet.

So they still leak.

Can you tell my patience on this patch set is very much running
out?  If you put half of the effort writing these patches as I
am putting into reviewing them, we wouldn't have to go back
and forth on this so many times.

Double check your work, and resubmit this whole patch set once you've
fixed this one, I think the other ones look fine.

Thanks.
