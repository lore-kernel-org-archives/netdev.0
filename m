From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/4] [NETLINK]: Handle NLM_F_ECHO in netlink_rcv_skb()
Date: Thu, 10 Aug 2006 23:18:33 +0200
Message-ID: <20060810211833.GK14627@postel.suug.ch>
References: <20060809204821.216122988@postel.suug.ch> <20060809205439.434010049@postel.suug.ch> <20060810155120.GA494@ms2.inr.ac.ru> <20060810190210.GH14627@postel.suug.ch> <20060810203252.GA6414@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:48832 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932070AbWHJVSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 17:18:13 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20060810203252.GA6414@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello

* Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> 2006-08-11 00:32
> Nothing! NLM_F_ECHO _is_ listening for notifications without subscription
> to multicast groups and need to figure out what messages are yours.
> But beyond this NLM_F_ECHO is totally subset of this.
> Which still makes much more sense then echoing of a know thing, does not it?

I get your point and I see the value. Unfortunately, probably due to
lack of documentation, this feature isn't used by any applications I
know of. We even put in the hacks to make identification of own caused
notifications easier by storing the netlink pid of the originator in
the notification message.

I will put this back in (document it! :) and hide it behind
nlmsg_notify() so we do it for all notifications for consistency.

I use echoing of the original request for debuging purposes, it allows
to verify what is actually being parsed at the netlink family specific
parsing function. Using libnl a flag enables NLM_F_ECHO in all messages
and it gets simple to verify what exactly is being seen in the kernel side
parser by looking at the messages log. I agree, there is no functional
value besides the possibility to implement a netlink ping with NLMSG_NOOP.
