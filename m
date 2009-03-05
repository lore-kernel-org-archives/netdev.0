From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] 2.6.29-rc* QinQ vlan trunking regression
Date: Wed, 04 Mar 2009 22:57:19 -0800 (PST)
Message-ID: <20090304.225719.159854470.davem@davemloft.net>
References: <49AE69DD.80802@trash.net>
	<20090304.195328.106253933.davem@davemloft.net>
	<49AF685D.90907@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bart@jukie.net, greearb@candelatech.com, shemminger@vyatta.com,
	dada1@cosmosbay.com, frank.blaschka@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50161
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750786AbZCEG5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 01:57:35 -0500
In-Reply-To: <49AF685D.90907@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 05 Mar 2009 06:51:25 +0100

> David Miller wrote:
> > From: Patrick McHardy <kaber@trash.net>
> > Date: Wed, 04 Mar 2009 12:45:33 +0100
> > 
> >> This is a bit tricky to fix since we actually need some valid
> >> ops before invoking ->init(). One way would be to move the compat
> >> ops initialization to a seperate function and have VLAN use it to
> >> switch its ops.
> > Mind if I push this into net-2.6?
> > vlan: Fix vlan-in-vlan crashes.
> > As analyzed by Patrick McHardy, vlan needs to reset it's
> > netdev_ops pointer in it's ->init() function but this
> > leaves the compat method pointers stale.
> > Add a netdev_resync_ops() and call it from the vlan code.
> 
> This looks fine, thanks. Even if it doesn't fix this particular
> report, I think its appropriate for net-2.6.

Thanks for looking at it, but I don't want to push it out until we
fully resolve this bug.
