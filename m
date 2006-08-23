From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: ProxyARP and IPSec
Date: Thu, 24 Aug 2006 03:18:12 +0400
Message-ID: <20060823231812.GA32394@ms2.inr.ac.ru>
References: <44EBA1FC.5000801@zytor.com> <20060823191425.GK3470@postel.suug.ch> <20060823.151424.78711856.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, hpa@zytor.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:20203 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S965299AbWHWXSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 19:18:35 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060823.151424.78711856.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> What he's trying to accomplish doesn't sound all that weird,

Absolutely sane.


> does anyone have any other ideas?

The question is where is this host really?

If it is far far away and connected only via IPsec tunnel with destionation
of tunnel different of host address

ip ro add THEHOST dev dummy0

should be enough. It asserts that THEHOST is not on eth0.
IPsec policy will figure out correct route, unless something is broken.

If tunnel endpoint is THEHOST, then it is necessary to make a prescription
how to reach it bypassing IPsec. This can be made with a rule telling
that THEHOST is reachable from router and only from router:

ip ru add from OUR_TUNNEL_ENDPOINT to THEHOST table XXX
ip ro add THEHOST via THAT_ROUTE_WHICH_IS_SUPPOSED_TO_KNOW table XXX

Alexey
