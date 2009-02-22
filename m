From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] bonding: move IPv6 support into a separate kernel module
Date: Sun, 22 Feb 2009 09:27:17 +0100
Message-ID: <20090222082717.GS5038@1wt.eu>
References: <499F4B61.3050508@hp.com> <20090221.235901.244910753.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: brian.haley@hp.com, arvidjaar@mail.ru, vladislav.yasevich@hp.com,
	chuck.lever@oracle.com, tytso@mit.edu, Valdis.Kletnieks@vt.edu,
	rjw@sisk.pl, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, jamagallon@ono.com,
	linux-kernel@vger.kernel.org, fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2411 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751969AbZBVI2O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Feb 2009 03:28:14 -0500
Content-Disposition: inline
In-Reply-To: <20090221.235901.244910753.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 21, 2009 at 11:59:01PM -0800, David Miller wrote:
> From: Brian Haley <brian.haley@hp.com>
> Date: Fri, 20 Feb 2009 19:31:29 -0500
> 
> > [Possible fix for bonding IPv6 regression reported by Andrey Borzenkov,
> > tried to keep all Cc's]
> > 
> > This patch moves the IPv6 bonding code into a separate kernel module
> > called bonding_ipv6 if either bonding or IPv6 are built as modules.
> > If both are built into the kernel then this is as well.  Bonding_ipv6.ko
> > registers an "send_unsol_na" function pointer for the unsolicited
> > advertisement function to be called on a failover - the default action
> > is to do nothing.  The notifier callbacks are now registered in this
> > module and not in the base bonding module.
> > 
> > Signed-off-by: Brian Haley <brian.haley@hp.com>
> 
> Thanks for taking the time to work on this Brian.
> 
> I wonder if we aren't just trading one evil for another.
> 
> Right now just configuring bonding will get the bonding
> module loaded and the ipv6 facilities will be visible.
> 
> Now with your change, the user has to explicitly load
> the module.  That's extremely user-unfriendly.

Especially since bonding is working between layers 1 and 2 and provides
a protocol-agnostic ethernet-like interface. It would seem very confusing
to load ethernet drivers depending on the protocols we expect to run on
top of them :-/

Willy

