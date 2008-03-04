From: David Miller <davem@davemloft.net>
Subject: Re: [patch 04/11][NETNS][IPV6] ip6_fib - add net to gc timer
 parameter
Date: Mon, 03 Mar 2008 23:29:07 -0800 (PST)
Message-ID: <20080303.232907.120828308.davem@davemloft.net>
References: <20080302093720.649869114@mai.toulouse-stg.fr.ibm.com>
	<20080302094153.627158693@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49684
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752601AbYCDH3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 02:29:08 -0500
In-Reply-To: <20080302094153.627158693@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Sun, 02 Mar 2008 10:37:24 +0100

> The fib tables are now relative to the network namespace. When the 
> garbage collector timer expires, we must have a network namespace 
> parameter in order to retrieve the tables. For now this is the 
> init_net, but we should be able to have a timer per namespace and 
> use the timer callback parameter to pass the network namespace from 
> the expired timer.
> 
> The timer callback, fib6_run_gc, is actually used to be called 
> synchronously by some functions and asynchronously when the timer 
> expires.
> 
> When the timer expires, the delay specified for fib6_run_gc parameter
> is always zero. So, I changed fib6_run_gc to not be a timer callback
> but a function called by the timer callback and I added a timer callback
> where its work is just to retrieve from the data arg of the timer the 
> network namespace and call fib6_run_gc with zero expiring time and
> the network namespace parameters. That makes the code cleaner for the
> fib6_run_gc callers.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

Applied.
