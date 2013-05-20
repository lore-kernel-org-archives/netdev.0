From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net]  vxlan: revert per-vxlan port
Date: Mon, 20 May 2013 14:15:59 -0400
Message-ID: <OFECE722DE.3DBEE821-ON85257B71.00610478-85257B71.006456B5@us.ibm.com>
References: <20130520103017.054ae605@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:40994 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756018Ab3ETSQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 May 2013 14:16:37 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Mon, 20 May 2013 14:16:36 -0400
In-Reply-To: <20130520103017.054ae605@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Stephen Hemminger <stephen@networkplumber.org>
 
> \This commit 823aa873bc782f1c51b1ce8ec6da7cfcaf93836e
> Author: stephen hemminger <stephen@networkplumber.org>
> Date:   Sat Apr 27 11:31:57 2013 +0000
> 
>     vxlan: allow choosing destination port per vxlan
> 
> is broken revert it. The change allowed setting per port for transmit
> but did not add additional listening sockets, which made any vxlan's
> defined with non-default port send only.

This allows you to specify a different default port for
transmits, which is what you want to do if your own instance
of VXLAN is the odd one. I don't see any requirement for multiple
listen ports for that to be useful, since those sending to you
can have complete fdb tables even if the local instance doesn't
and relies on the default. Not to mention using an agent to
fill the fdb triggered by packets sent to the default, so the
receiver is not necessarily even a VXLAN instance. The receiver
side and transmit side ports can be completely independent of
each other, as in any other client-server system.

I think an administrator should have full flexibility to specify
the ports and destinations as s/he sees fit and if you don't think
that's a useful feature, you don't have to use it; the defaults
work fine, too.

                                                        +-DLS
