From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Fw: unregister_netdevice(): negative refcnt, suggest patch against 2.6.11
Date: Mon, 11 Apr 2005 14:51:13 +0200
Message-ID: <20050411125113.GL26731@postel.suug.ch>
References: <20050410034446.39e3025e.akpm@osdl.org> <20050410212727.GA13829@palmen.homeip.net> <20050410215050.GJ26731@postel.suug.ch> <20050411023038.GB13829@palmen.homeip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Felix Palmen <fmp@palmen.homeip.net>
Content-Disposition: inline
In-Reply-To: <20050411023038.GB13829@palmen.homeip.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Felix Palmen <20050411023038.GB13829@palmen.homeip.net> 2005-04-11 04:30
> * Thomas Graf <tgraf@suug.ch> [20050410 23:50]:
> > Is it always 256? Do you have any appletalk routes configured?
> > If so, is the 256 dependand on the number of routes?
> 
> That could really be the case:
> 
> - In my test with vanilla 2.6.11.7, there was no other appletalk
>   station on the net -> refcnt was -256

How long was the interface up before you removed it again? That 256
might be due to probes still floating around expiring very slowly
because there is no other station around.

> - On my working system, I use a single route and get refcnt = -1

This one I can explain quite easly, I did not found a dev_hold()
for the dev_put() that is done upon deletion of the routes when
the interface is removed.

> - When I first tried appletalk without configuring anything but the
>   interface and PearPC with Mac OS X runnning on the other side, refcnt
>   was -2

OK, I think the problem is a few missing dev_hold() when the net_device
handle is assigned to routes, probes, etc.
