From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] macvtap: rework object lifetime rules
Date: Thu, 18 Feb 2010 14:11:26 -0800 (PST)
Message-ID: <20100218.141126.38076586.davem@davemloft.net>
References: <20100215.215341.66627877.davem@davemloft.net>
	<201002181644.29740.arnd@arndb.de>
	<201002181645.36426.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, kaber@trash.net, eswierk@aristanetworks.com,
	netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50825
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753153Ab0BRWLL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 17:11:11 -0500
In-Reply-To: <201002181645.36426.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 18 Feb 2010 16:45:36 +0100

> This reworks the change done by the previous patch
> in a more complete way.
> 
> The original macvtap code has a number of problems
> resulting from the use of RCU for protecting the
> access to struct macvtap_queue from open files.
> 
> This includes
> - need for GFP_ATOMIC allocations for skbs
> - potential deadlocks when copy_*_user sleeps
> - inability to work with vhost-net
> 
> Changing the lifetime of macvtap_queue to always
> depend on the open file solves all these. The
> RCU reference simply moves one step down to
> the reference on the macvlan_dev, which we
> only need for nonblocking operations.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
