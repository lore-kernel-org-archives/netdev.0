From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] allow VLAN interface on top of bridge interface
Date: Thu, 12 Apr 2007 15:01:05 -0700 (PDT)
Message-ID: <20070412.150105.45898545.davem@davemloft.net>
References: <20070412143456.2e4019f0.akpm@linux-foundation.org>
	<461EA863.9020702@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	j.borsboom@erasmusmc.nl
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48708
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030802AbXDLWBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2007 18:01:05 -0400
In-Reply-To: <461EA863.9020702@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Thu, 12 Apr 2007 14:45:07 -0700

> Andrew Morton wrote:
> > 
> > Begin forwarded message:
> > 
> > Date: Thu, 12 Apr 2007 21:50:00 +0200 (CEST)
> > From: Jerome Borsboom <j.borsboom@erasmusmc.nl>
> > To: linux-kernel@vger.kernel.org
> > Subject: [PATCH] allow VLAN interface on top of bridge interface
> > 
> > 
> > When a VLAN interface is created on top of a bridge interface and 
> > netfilter is enabled to see the bridged packets, the packets can be 
> > corrupted when passing through the netfilter code. This is caused by the 
> > VLAN driver not setting the 'protocol' and 'nh' members of the sk_buff 
> > structure. In general, this is no problem as the VLAN interface is mostly 
> > connected to a physical ethernet interface which does not use the 
> > 'protocol' and 'nh' members. For a bridge interface, however, these 
> > members do matter.
> 
> Why only do this inside that if clause?  I can see only setting
> nh.raw in that clause, but it seems like the protocol should be set
> regardless.

Because outside the if clause we are making the packet look
like a normal ethernet frame to the rest of the stack, and
only adding the VLAN tag at the very last moment in
->hard_start_xmit().
