From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 1/1]: bna: Fix build break for allyesconfig
Date: Wed, 25 Aug 2010 15:22:43 -0700 (PDT)
Message-ID: <20100825.152243.260093985.davem@davemloft.net>
References: <201008252132.o7PLWA0j029512@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amathur@brocade.com, ddutt@brocade.com,
	huangj@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38564
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752381Ab0HYWW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 18:22:28 -0400
In-Reply-To: <201008252132.o7PLWA0j029512@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Wed, 25 Aug 2010 14:32:10 -0700

> From: Rasesh Mody <rmody@brocade.com>
> 
> This patch contains a fix for the build break caused by multiple
> definitions of symbols between Brocade's FC/FCOE driver(BFA) 
> and 10G Networking Driver(BNA).
> 
> The fix is to make BNA a module only driver.
> 
> Signed-off-by: Debashis Dutt <ddutt@brocade.com>
> Signed-off-by: Rasesh Mody <rmody@brocade.com>

You have to be kidding me.  This fix is totally unacceptable.

You have to go through your two drivers and:

1) Mark as 'static' symbols that don't actually need global
   visibility.

2) Make the two drivers use unique namespaces for the function
   names that must be globally visible for whatever reason.

You are really trying my patience, fix this properly and promptly
or I'm removing your driver from the tree.
