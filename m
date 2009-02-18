From: Patrick McHardy <kaber@trash.net>
Subject: Re: [BUG] SNAT sometimes allows packets to pass through unchanged
Date: Wed, 18 Feb 2009 17:58:28 +0100
Message-ID: <499C3E34.7080405@trash.net>
References: <Pine.LNX.4.44L0.0902181140120.17341-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58002 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052AbZBRQ6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 11:58:31 -0500
In-Reply-To: <Pine.LNX.4.44L0.0902181140120.17341-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alan Stern wrote:
> On Mon, 16 Feb 2009, Patrick McHardy wrote:
> 
>> The NAT table only sees the first packet of every connection
>> and never INVALID packets. The mangle table should work fine.
> 
> I ended up adding a rule to the FORWARD chain of the filter table.  
> The trick was to select based on the state.  That worked; it saw all
> those un-NATed packets and was able to eliminate them.  In case you're
> curious, the rule was essentially this:
> 
> iptables -A FORWARD -o eth1 -s 10.0.0.0/8 -m state --state INVALID -j DROP
 >
> Ideally, the rule should select all the packets which haven't been
> altered by SNAT, not just the ones marked INVALID.  Is there any way to
> do this?

Not in the sense that you could somehow catch valid packets "missed"
by SNAT, that would be a bug. The conntrack match supports matching
on whether the state says that a packet should be NATed.
