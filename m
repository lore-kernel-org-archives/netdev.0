From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [RFC IPv6] Disabling IPv6 autoconf
Date: Tue, 29 Aug 2006 20:30:03 +0400
Message-ID: <20060829163003.GA30408@ms2.inr.ac.ru>
References: <20060829082435.GA2676@suse.de> <20060829.183426.52410264.yoshfuji@linux-ipv6.org> <20060829.025400.37356422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, okir@suse.de, netdev@vger.kernel.org,
	jbeulich@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:24472 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S965066AbWH2Qas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:30:48 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060829.025400.37356422.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Yes, it is logical because without multicast IPV6 cannot
> work correctly.

This is not quite true. IFF_BROADCAST is enough, it will work just
like IPv4.

Real troubles start only when interface is not IFF_BROADCAST and not
IFF_POINTOPOINT.


> IFF_MULTICAST flag seems potentially problematic.  How many other
> things break over such a device?

Nothing should break. IFF_MULTICAST is an advisory flag, saying
mostly "You do not want to stream high bandwidth multicast video here".
So that, it can be used to block autoconfiguration.

It does not change the fact that Xen device makes something profoundly
wrong. IPv6 autoconfiguration is _auto_configuration. It is triggered
only for a few of media types, for which autoconfiguration is prescribed
by corresponding RFCs. Ethernet is one of them.

If Xen does not support the things, which are required for each
ethernet device, it should not be ARPHRD_ETHER. If it wants to pretend
to be ARPHRD_ETHER, it must support basic ethernet functions, which IMHO
is so _easy_, that the question does not even makes sense.

Alexey
