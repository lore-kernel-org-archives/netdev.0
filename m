From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 16120] New: Oops: 0000 [#1] SMP, unable to
 handle kernel NULL pointer dereference at (null)
Date: Mon, 07 Jun 2010 02:58:29 -0700 (PDT)
Message-ID: <20100607.025829.186328961.davem@davemloft.net>
References: <1275729426.5238.6.camel@edumazet-laptop>
	<1275730457.5238.14.camel@edumazet-laptop>
	<1275904120.2545.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, alex.vizor@gmail.com,
	kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42157
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752662Ab0FGJ6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 05:58:20 -0400
In-Reply-To: <1275904120.2545.40.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 07 Jun 2010 11:48:40 +0200

> [PATCH net-2.6] ipmr: dont corrupt lists
> 
> ipmr_rules_exit() and ip6mr_rules_exit() free a list of items, but
> forget to properly remove these items from list. List head is not
> changed and still points to freed memory.
> 
> This can trigger a fault later when icmpv6_sk_exit() is called.
> 
> Fix is to either reinit list, or use list_del() to properly remove items
> from list before freeing them.
> 
> bugzilla report : https://bugzilla.kernel.org/show_bug.cgi?id=16120
> 
> Introduced by commit d1db275dd3f6e4 (ipv6: ip6mr: support multiple
> tables) and commit f0ad0860d01e (ipv4: ipmr: support multiple tables)
> 
> Reported-by: Alex Zhavnerchik <alex.vizor@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Patrick McHardy <kaber@trash.net>

Applied, thanks a lot Eric.
