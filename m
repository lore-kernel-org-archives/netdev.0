From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC] Stable interface index option
Date: Wed, 2 Dec 2015 02:41:18 +0100
Message-ID: <20151202014118.GD29814@lunn.ch>
References: <20151201153441.GA17843@oracle.com>
 <20151201155052.GA14984@principal.rfc2324.org>
 <1448985743.3387258.454809153.36540D70@webmail.messagingengine.com>
 <20151201.142749.1921315575696738796.davem@davemloft.net>
 <1449001579.3817695.455078657.261B9C10@webmail.messagingengine.com>
 <20151201224325.GD14984@principal.rfc2324.org>
 <1449014338.3866712.455236865.50F81F7F@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maximilian Wilhelm <max@rfc2324.org>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50953 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754905AbbLBBlW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2015 20:41:22 -0500
Content-Disposition: inline
In-Reply-To: <1449014338.3866712.455236865.50F81F7F@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> In general the ifindexes are designed to not be reused very fast.

Some parts of multicast group management rely on this. You need to
remove group memberships from a socket when an interface has
disappeared, e.g. a VPN interface has gone away. You can pass the
ifindex of the no longer existing interface when removing the group
memberships. If that ifindex has been re-used, you are going to have
interesting race conditions.

	    Andrew
