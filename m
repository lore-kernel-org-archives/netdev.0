From: David Miller <davem@davemloft.net>
Subject: Re: [Bonding-devel] 2.6.29 regression? Bonding tied to IPV6 in
 29-rc5
Date: Tue, 17 Feb 2009 14:49:58 -0800 (PST)
Message-ID: <20090217.144958.69599007.davem@davemloft.net>
References: <200902172001.41804.arvidjaar@mail.ru>
	<200902172117.22671.arvidjaar@mail.ru>
	<13225.1234901283@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arvidjaar@mail.ru, rjw@sisk.pl, brian.haley@hp.com,
	netdev@vger.kernel.org, jamagallon@ono.com,
	bonding-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37335
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751959AbZBQWuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 17:50:14 -0500
In-Reply-To: <13225.1234901283@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Tue, 17 Feb 2009 12:08:03 -0800

> 	The simple answer (don't turn on CONFIG_IPV6) isn't really
> useful for the common case of distro kernels, which will generally have
> CONFIG_IPV6 enabled.

This whole "disable ipv6 module load in /etc/modules.conf" was
bound to eventually cause problems like this.

There are so many chicken-and-egg issues wrt. this it isn't
even funny, for example:

1) If we provide a sysctl which is a bitmask of protocols
   to disallow registering, we have the same problem we have
   now since ipv6 won't be able to load when the sock_register()
   fails.

2) If we add some ipv6 sysctl that says "don't do ipv6" so the
   module can load yet not automatically add link local ipv6
   addresses to interfaces and solicit for routers on the network,
   the sysctl can't be set until the module is loaded.

And this bonding stuff in particular wants to get into the
neighbour discovery state of the ipv6 module.  Therefore it's
not like we can split out a few functions into some kind
of "ipv6_helpers.ko" kernel module to eliminate the problem
either.
