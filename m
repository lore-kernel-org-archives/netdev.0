From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6]: rtnl: make link af-specific updates
 atomic
Date: Sat, 27 Nov 2010 22:56:28 -0800 (PST)
Message-ID: <20101127.225628.39167961.davem@davemloft.net>
References: <20101122113154.GA16382@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35851
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751662Ab0K1G4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 01:56:02 -0500
In-Reply-To: <20101122113154.GA16382@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@infradead.org>
Date: Mon, 22 Nov 2010 06:31:54 -0500

> As David pointed out correctly, updates to af-specific attributes
> are currently not atomic. If multiple changes are requested and
> one of them fails, previous updates may have been applied already
> leaving the link behind in a undefined state.
> 
> This patch splits the function parse_link_af() into two functions
> validate_link_af() and set_link_at(). validate_link_af() is placed
> to validate_linkmsg() check for errors as early as possible before
> any changes to the link have been made. set_link_af() is called to
> commit the changes later.
> 
> This method is not fail proof, while it is currently sufficient
> to make set_link_af() inerrable and thus 100% atomic, the
> validation function method will not be able to detect all error
> scenarios in the future, there will likely always be errors
> depending on states which are f.e. not protected by rtnl_mutex
> and thus may change between validation and setting.
> 
> Also, instead of silently ignoring unknown address families and
> config blocks for address families which did not register a set
> function the errors EAFNOSUPPORT respectively EOPNOSUPPORT are
> returned to avoid comitting 4 out of 5 update requests without
> notifying the user.
> 
> Signed-off-by: Thomas Graf <tgraf@infradead.org>

Applied, thanks Thomas.
