From: David Miller <davem@davemloft.net>
Subject: Re: ixgbe: [RFC] [PATCH] Fix return of invalid txq
Date: Fri, 15 Jan 2010 00:44:56 -0800 (PST)
Message-ID: <20100115.004456.15627093.davem@davemloft.net>
References: <20100115053117.31513.82775.sendpatchset@krkumar2.in.ibm.com>
	<F86E8680A7D9D74A99DC6345E35A692950158650@orsmsx503.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37407
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751835Ab0AOIor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 03:44:47 -0500
In-Reply-To: <F86E8680A7D9D74A99DC6345E35A692950158650@orsmsx503.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Thu, 14 Jan 2010 23:58:17 -0800

> I've been trying to find time to add something like igb has, with a
> tiny Tx lookup table that maps CPUs into a smaller set of Tx queues.

Why do you need "tables"?  Just modulo the it, with whatever
optimizations you can come up with.

Or do we not have enough data references in the TX path already?
:-/

I would suggest getting rid of the table in IGB too.

Either "tables" are a good idea (I think they definitely are not)
or they are not.  And whatever the decision is we should do it
consistently.  net/core/dev.c doesn't use tables, it does the
subtraction modulo thing like Krishna does.

