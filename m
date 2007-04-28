From: olof@lixom.net (Olof Johansson)
Subject: Re: [RESEND] [PATCH v2] [1/5] pasemi_mac: minor bugfixes
Date: Sat, 28 Apr 2007 11:17:25 -0500
Message-ID: <20070428161725.GA2442@lixom.net>
References: <20070428054952.GA22074@lixom.net> <20070428055023.GB22074@lixom.net> <46336631.9070501@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:59982 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753863AbXD1QQu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 12:16:50 -0400
Content-Disposition: inline
In-Reply-To: <46336631.9070501@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 28, 2007 at 11:20:17AM -0400, Jeff Garzik wrote:

> >+	if (was_full)
> >+		netif_wake_queue(mac->netdev);
> >+
> 
> Isn't this was_full check redundant?  Using standard test-and-clear 
> atomic logic, netif_wake_queue() will not issue spurious wakeups.  Take 
> a look at its implementation in include/linux/netdevice.h.

It's not needed to avoid spurious wakeups, but test_and_clear_bit()
results in an atomic op even if the bit is already clear. I.e. it's a
bit heavy-handed to do if you can already know that it isn't set.

Either way it's no big deal, I'll take out the test for now. It can always
be added back in if it starts to climb on profiles when benchmarking.


-Olof
