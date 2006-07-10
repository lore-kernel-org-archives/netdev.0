From: David Miller <davem@davemloft.net>
Subject: Re: active-backup/bonding with drivers not supporting
 set_mac_address()
Date: Mon, 10 Jul 2006 11:23:22 -0700 (PDT)
Message-ID: <20060710.112322.100334803.davem@davemloft.net>
References: <Pine.LNX.4.64.0607101618390.26558@zuben>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19397
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422745AbWGJSWj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 14:22:39 -0400
To: ogerlitz@voltaire.com
In-Reply-To: <Pine.LNX.4.64.0607101618390.26558@zuben>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Or Gerlitz <ogerlitz@voltaire.com>
Date: Mon, 10 Jul 2006 16:43:36 +0300 (IDT)

> Looking on the linux bonding driver, it seems to unconditionally (*)
> assume that the enslaved device supports the set_mac_address call.
> 
> >From reading the doc (Documentation/networking/bonding.txt) i understand that
> it is **not** a must prerequisite for the active-backup mode, this is since
> there is at most one active slave at each point of time and as the doc states:
> 
> 	when a failover occurs in active-backup mode, bonding will issue
> 	one or more gratuitous ARPs on the newly active slave.
> 
> I'd like to get feedback from people here if you think it makes sense
> to change the bonding driver to actually allow for active-backup/bonding
> with network device drivers which does not support set_mac_address.

Blindly dereferencing the ->set_mac_address method is wrong, it
does seem.

Regardless of whether we add support for active-backup/bonding for
devices without this method, in the mean time the bonding
driver should check for whether that method is NULL and disallow
the bond configuration if it is.
