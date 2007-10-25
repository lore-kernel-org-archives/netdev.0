From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Regression in current git - Network Manager fails (bisected)
Date: Thu, 25 Oct 2007 11:06:09 +0200
Message-ID: <20071025090609.GD8125@postel.suug.ch>
References: <20071022005857.GA6317@nineveh.local> <471C6BEC.4010604@sw.ru> <1193068645.30205.22.camel@localhost.localdomain> <20071023121123.GA8125@postel.suug.ch> <471DF28D.3030904@sw.ru> <20071023133823.GB8125@postel.suug.ch> <1193148618.8648.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Denis V. Lunev" <den@sw.ru>, netdev@vger.kernel.org,
	"Denis V. Lunev" <den@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:35823 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750736AbXJYJFt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 05:05:49 -0400
Content-Disposition: inline
In-Reply-To: <1193148618.8648.22.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Dan Williams <dcbw@redhat.com> 2007-10-23 10:10
> Should I make NM disable ACKs for now until it gets fixed?

The reason libnl enables ACKs by default is to give the
application using it clear synchronisation points. For
change requests that means the interface function won't
return until the change has been commited as it will
call nl_wait_for_ack(). So if you disable it in NM and
run it on "old" kernels still using async netlink you
won't be sure when the change is actually being done so
this might break things if you rely on it.

I think providing a invalid message handler which returns
NL_OK if nlmsg_type is NLMSG_DONE or NLMSG_ERROR && err == 0
would be better if you need some kind of workaround. As
those messages are always last this should never cause
real troubles.
