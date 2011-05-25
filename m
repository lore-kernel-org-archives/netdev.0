From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] af-packet: Save reference to bound network device.
Date: Wed, 25 May 2011 18:01:13 -0400 (EDT)
Message-ID: <20110525.180113.1194226831134092545.davem@davemloft.net>
References: <1306360602-9672-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34301 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932309Ab1EYWBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 18:01:17 -0400
In-Reply-To: <1306360602-9672-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: greearb@candelatech.com
Date: Wed, 25 May 2011 14:56:42 -0700

> From: Ben Greear <greearb@candelatech.com>
> 
> This saves a network device lookup on each packet transmitted,
> for sockets that are bound to a network device.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>

You can't hold onto devices like this unless you also add a netdev
event notifier that will release it.  Otherwise we'll hang on net
driver module unload until the packet socket is closed.

I don't think you really want to walk all pf-packet sockets on netdev
events just to do this.

dev_get_by_index(,_rcu}() is insanely cheap, I doubt it's showing up
on your profiles at all.
