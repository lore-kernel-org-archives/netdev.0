From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: smc91x: Fix build without gpiolib
Date: Fri, 12 Dec 2014 11:58:38 -0500 (EST)
Message-ID: <20141212.115838.1155760587618419145.davem@davemloft.net>
References: <20141212162746.GJ16916@distanz.ch>
	<20141212.113020.884577050283133272.davem@davemloft.net>
	<20141212164528.GK16916@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tony@atomide.com, nico@fluxnic.net, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36363 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932185AbaLLQ6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 11:58:41 -0500
In-Reply-To: <20141212164528.GK16916@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Fri, 12 Dec 2014 17:45:29 +0100

> On 2014-12-12 at 17:30:20 +0100, David Miller <davem@davemloft.net> wrote:
>> In my opinion, if the code blocks enabling the configurations that
>> need this are enabled, so should GPIO be depended upon.
>> 
>> I think, at a minimum, when CONFIG_OF is enabled smsc91x should
>> require GPIO.
> 
> Agreed. This is the better solution, causing less surprises for the
> user. Should this be a "select GPIOLIB if OF" then?

If GPIO is a child node in the Kconfig hierarchy (ie. has no
dependencies of it's own), then yes.  Otherwise, a depends
will need to be used, because select does not recursively
trigger a select'd nodes dependencies.
