From: David Miller <davem@davemloft.net>
Subject: Re: take#2: [PATCH] [ATM]: Add error handling for proc_create fail
Date: Sun, 02 Mar 2008 21:09:26 -0800 (PST)
Message-ID: <20080302.210926.16120136.davem@davemloft.net>
References: <47C7B79C.2010304@cn.fujitsu.com>
	<20080229.103803.151963676.davem@davemloft.net>
	<47CB6611.30004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chas3@users.sourceforge.net
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46990
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751410AbYCCFJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 00:09:26 -0500
In-Reply-To: <47CB6611.30004@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Mon, 03 Mar 2008 10:44:33 +0800

> David Miller said the following on 2008-3-1 2:38:
> > This is not sufficient.  If this fails you need to unregister
> > the ioctl and all of the other things that get registered
> > before this procfs registry runs.
> > 
> 
> When proc_create() fail, we return -ENOMEM.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Sigh....

I know you want to avoid all of the error handling unwind code, but
you can't do that in this situation.  It's not valid to register the
ATM clip procfs file without first initializing the ATM clip neighbour
table, so moving it up like this isn't going to work.

They way you've done it, a user can open the procfs file and access
the datastructure before it's initialized properly.

Please, simply add the necessary unregister code and leave the procfs
initialization where it currently is.

I get the sense you really aren't reading this code carefully and
you're tossing these patches together as quickly as you can to just
get it done.  Please don't do that, it wastes both my time and
your's.

Thank you.
