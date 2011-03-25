From: David Miller <davem@davemloft.net>
Subject: Re: disabling ipv6 (when ipv6 module is already loaded or built in)
Date: Fri, 25 Mar 2011 15:56:57 -0700 (PDT)
Message-ID: <20110325.155657.193733904.davem@davemloft.net>
References: <201103251817.04583.a.miskiewicz@gmail.com>
	<4D8CF970.7020601@hp.com>
	<201103252353.06297.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, netdev@vger.kernel.org
To: a.miskiewicz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46940
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752959Ab1CYW4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2011 18:56:18 -0400
In-Reply-To: <201103252353.06297.a.miskiewicz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Date: Fri, 25 Mar 2011 23:53:06 +0100

> The whole problem is that socket(AF_INET6,...) is allowed. If setting 
> net.ipv6.conf.all.disable_ipv6=1 would also prevent such socket() from 
> succeeding then everything would be fine.

You have to make this setting before the module loads, once we register
the protocol handlers (which is what allows socket() to succeed) the
cat is out of the bag.

If even just one socket exists, we can't perform the steps necessary
to block new ones.

That's why you have to use the module option, and it is the only way
to block this class of operations.
