From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [NET_SCHED]: cls_fw: fix NULL pointer dereference
Date: Mon, 4 Dec 2006 17:59:22 +0100
Message-ID: <20061204165922.GT8693@postel.suug.ch>
References: <45744016.8080707@trash.net> <1165249502.3643.9.camel@localhost> <20061204162823.GQ8693@postel.suug.ch> <45744F41.8020609@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:38199 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937154AbWLDQ7D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 11:59:03 -0500
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <45744F41.8020609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> 2006-12-04 17:39
> It just seems this code is entirely useless and the only
> thing it does is cause short term unexpected behaviour
> during the race I mentioned.

Yes, the whole head == NULL branch should be removed.

> One thing we should probably do is to move the tp->root
> allocation to the init function in cls_fw and the others
> implementing it as dummy to at least close the race
> between ->init and ->change. I'll look into that as a
> follow-up patch.

Right, allocating the head in init with a mask of 0xFFFFFFFF
and then allow the user to overwrite it seems to make most
sense.
