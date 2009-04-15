From: David Miller <davem@davemloft.net>
Subject: Re: An inconsistency/bug in ingress netem timestamps
Date: Wed, 15 Apr 2009 16:41:42 -0700 (PDT)
Message-ID: <20090415.164142.193730680.davem@davemloft.net>
References: <20090415202620.GB3322@ami.dom.local>
	<20090415132918.7579ffa6@nehalam>
	<200904151700.59906.alexandre.sidorenko@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, jarkao2@gmail.com, netdev@vger.kernel.org
To: alexandre.sidorenko@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32874
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751761AbZDOXlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 19:41:51 -0400
In-Reply-To: <200904151700.59906.alexandre.sidorenko@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Sidorenko <alexandre.sidorenko@hp.com>
Date: Wed, 15 Apr 2009 17:00:59 -0400

> the timestamps change depending on whether there are any ptype_all handlers 
> registered. Just starting tcpdump changes the behaviour, this probably 
> means 'inconsistent' ?

It changes whether there is a "timestamp user" and packet sniffers are
currently defined as such as user.

The argument is whether the overhead of making this type of use
a "timestamp user" is warranted or not.

Turning on timestamps is heavily optimized like this because taking
the timestamp on every packet is extremely expensive, especially
on large classes of x86 systems.

Therefore if we make changes here, they have to have a very specific
and limited scope in order to avoid turning this expensive operation
on when it's not really necessary.
