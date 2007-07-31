From: David Miller <davem@davemloft.net>
Subject: Re: fscked clock sources revisited
Date: Mon, 30 Jul 2007 18:37:50 -0700 (PDT)
Message-ID: <20070730.183750.77058266.davem@davemloft.net>
References: <1185844239.5162.17.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, kaber@trash.net
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40183
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751417AbXGaBh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 21:37:59 -0400
In-Reply-To: <1185844239.5162.17.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Mon, 30 Jul 2007 21:10:39 -0400

> acpi_pm: 108, 110, 111,  91, 108
> tsc:     143, 108, 161, 129, 108
> jiffies: 132, 138, 132, 146, 150
> 
> jiffies produces better results than tsc which produces better results
> than acpi_pm. 

Relatively speaking, the acpi_pm numbers are at least consistent and
about as much as so as jiffies.  Jiffies numbers are also possibly
better, at least in part, because of the decreased accuracy and errors
propagating.

tsc acts as expected, since every time your cpu changes power
management state (which it is going to do dynamically) the TSC
rates change and thus the accuracy goes into outer-space.

There really isn't much that can be done by any of this.  These issues
exist because of hardware limitations, nobody bothered to build
x86/x86_64 systems with a system wide TICK register that is both
impervious to cpu frequence scaling and also cheap to access.

So the above is what we basically have to live with :-)
