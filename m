From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [Patch] net: kill an RCU warning in inet_fill_link_af()
Date: Wed, 1 Dec 2010 17:22:33 -0500
Message-ID: <20101201222233.GB22009@canuck.infradead.org>
References: <1291202063-6239-1-git-send-email-amwang@redhat.com>
 <1291219386.2856.924.camel@edumazet-laptop>
 <20101201171801.GA22009@canuck.infradead.org>
 <1291224717.2856.1021.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amerigo Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:50440 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195Ab0LAWWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 17:22:37 -0500
Content-Disposition: inline
In-Reply-To: <1291224717.2856.1021.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 01, 2010 at 06:31:57PM +0100, Eric Dumazet wrote:
> Are you sure RTNL is not held while dumping ? 
> 
> Patrick did the change to hold RTNL while dumping too, 3.5 years ago.
> Check commits 6313c1e0992fea, 1c2d670f3660e9103 ([RTNETLINK]: Hold
> rtnl_mutex during netlink dump callbacks)

You are right, I only looked at netlink_dump_start() where the lock
is released after setting ->cb.  We grab RTNL again in netlink_dump()
after allocating the skb.
