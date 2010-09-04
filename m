From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4_core: module param to limit msix vec allocation
Date: Fri, 03 Sep 2010 19:30:46 -0700 (PDT)
Message-ID: <20100903.193046.184840227.davem@davemloft.net>
References: <20100903203044.GN2464@sgi.com>
	<20100903.144658.149830788.davem@davemloft.net>
	<20100903221303.GS2464@sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: akepner@sgi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50830
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753436Ab0IDCa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 22:30:29 -0400
In-Reply-To: <20100903221303.GS2464@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arthur Kepner <akepner@sgi.com>
Date: Fri, 3 Sep 2010 15:13:03 -0700

> On Fri, Sep 03, 2010 at 02:46:58PM -0700, David Miller wrote:
>> No, you really can't do it this way, IRQ allocation management has to
>> be in the kernel.
> 
> Really? I was specifically trying to avoid that, and let the 
> policy about interrupt assignment be done in a user process. 
> 
> Do you have any specific ideas about how that'd look? 

Likely there would be a set of policies just like the cpu
power management layer we have.  And there would be a default,
and userland could override the default.

This also means there would have to be notifications sent to
drivers when the distribution and allocation policy of MSI-X
interrupts is changed.  This is so that, for example, network
drivers can reconfigure their network queues for the new set
of MSI-X vectors available to them after the policy change.
