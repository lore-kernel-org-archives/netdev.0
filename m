From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [BUG] SNAT sometimes allows packets to pass through unchanged
Date: Wed, 18 Feb 2009 11:49:58 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.0902181140120.17341-100000@iolanthe.rowland.org>
References: <49999393.3040105@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:33788 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752990AbZBRQt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 11:49:59 -0500
In-Reply-To: <49999393.3040105@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Feb 2009, Patrick McHardy wrote:

> The NAT table only sees the first packet of every connection
> and never INVALID packets. The mangle table should work fine.

I ended up adding a rule to the FORWARD chain of the filter table.  
The trick was to select based on the state.  That worked; it saw all
those un-NATed packets and was able to eliminate them.  In case you're
curious, the rule was essentially this:

iptables -A FORWARD -o eth1 -s 10.0.0.0/8 -m state --state INVALID -j DROP

Ideally, the rule should select all the packets which haven't been
altered by SNAT, not just the ones marked INVALID.  Is there any way to
do this?

Alan Stern

