From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 3/4] netxen: added sanity check for pci map
Date: Thu, 25 Mar 2010 12:04:46 -0700 (PDT)
Message-ID: <20100325.120446.98057142.davem@davemloft.net>
References: <1269500806-15383-1-git-send-email-amit.salecha@qlogic.com>
	<1269500806-15383-4-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38185
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754195Ab0CYTEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 15:04:24 -0400
In-Reply-To: <1269500806-15383-4-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
