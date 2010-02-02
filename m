From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: use helpers to access mc list
Date: Tue, 02 Feb 2010 07:25:33 -0800 (PST)
Message-ID: <20100202.072533.52179643.davem@davemloft.net>
References: <20100126145738.GA2537@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54065
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755456Ab0BBPZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 10:25:20 -0500
In-Reply-To: <20100126145738.GA2537@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 26 Jan 2010 15:57:39 +0100

> Temporary macro "netdev_for_each_mc_addr" works in the ugly way, I'm aware, but
> it will be replaced. It uses iterator stored in "struct net_device". In every
> iteration, it copies addr from the list to "struct netdev_hw_addr" instance
> (also stored in "struct net_device"). Driver reads address stored in this
> structure. All is protected by addr_list_lock held by a caller.

This kind of ugly hack is rarely necessary, so I'm not applying
this, sorry.

In the macros, use the iterator type the driver instances already use,
which is the mcaddr entry pointer.

Then by using list_for_each_entry() things should "just work".
