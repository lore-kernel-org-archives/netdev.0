From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to use rtnl_notify()
Date: Tue, 15 Aug 2006 13:17:35 +0200
Message-ID: <20060815111735.GU14627@postel.suug.ch>
References: <20060814213718.580598840@postel.suug.ch> <20060814214341.834971519@postel.suug.ch> <1155598991.6946.42.camel@jzny2> <20060815003614.GA8677@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:4064 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932486AbWHOLRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 07:17:15 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20060815003614.GA8677@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> 2006-08-15 04:36
> > Some of these removals of current->pid will affect users such as quagga,
> > zebra, vrrpd etc.
> 
> If they survived cleanup in IPv4, they definitely will not feel cleanup
> in IPv6.

That was exactly my thought, the notifications in question provide
a pid of 0 for their IPv4 counterparts therefore I considered it
safe.

However, I changed IPv4 addresses to provide the pid and support
NLM_F_ECHO and the same will follow for IPv6 address notifications
which will mean that quagga sees a different set of IPv4 address
notifications. It would be a bug on their side if that would cause
failure though.
