From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Fri, 28 Mar 2008 18:06:31 -0700 (PDT)
Message-ID: <20080328.180631.91055366.davem@davemloft.net>
References: <20080328000013.GA8193@codemonkey.org.uk>
	<20080328.173414.22278840.davem@davemloft.net>
	<1206752049.22530.105.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44163
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755962AbYC2BGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 21:06:31 -0400
In-Reply-To: <1206752049.22530.105.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Sat, 29 Mar 2008 01:54:09 +0100

> Maybe we should check which schedule_work users actually lock the rtnl
> within the work function and move them to a uses-rtnl-in-work workqueue
> so that everybody else can have rtnl around flush.

The issue is that linkwatch goes: workqueue lock --> RTNL

And thus taking workqueue lock within RTNL is deadlock
prone no matter where you do it.
