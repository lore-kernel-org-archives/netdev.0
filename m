From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH 1/2] Issue NETDEV_CHANGE notification when bridge
 changes state
Date: Sun, 6 Mar 2011 22:41:14 -0800 (PST)
Message-ID: <1649722795.14144.1299480074110.JavaMail.root@tahiti.vyatta.com>
References: <20110307002543.GA4242@mira.lan.galacticasoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Adam Majer <adamm@zombino.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60843 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751169Ab1CGGlP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 01:41:15 -0500
In-Reply-To: <20110307002543.GA4242@mira.lan.galacticasoftware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Sun, Mar 06, 2011 at 09:45:41AM -0800, Stephen Hemminger wrote:
> > Since this a generic problem, it needs a better solution.
> > Sending NETDEV_CHANGE impacts lots of other pieces, and even
> > user space has similar problems.
> 
> It does seem a little broad notification type. I've checked over
> all the currently defined NETDEV notifiers, and it seems that
> NETDEV_NOTIFY_PEERS may be a better option to use when bridge
> has a potential topology change.
> 
> Currently it is only used in ipv4/devinet.c: where it is used to issue
> a gratuitous ARP.

I was thinking of fixing bridge to not actually bring the link
up until in forwarding mode. Other applications (DHCP, etc)
see the link up and really don't like being in half duplex
during that period. 
