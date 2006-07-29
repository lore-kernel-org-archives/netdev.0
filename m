From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RESEND 3/5] [NET]: Protocol Independant Policy Routing Rules
 Framework
Date: Sat, 29 Jul 2006 03:40:13 +0200
Message-ID: <44CABC7D.2080903@trash.net>
References: <20060726221100.325687073@postel.suug.ch>	 <20060726221849.807482409@postel.suug.ch>	 <Pine.LNX.4.64.0607270158001.4779@d.namei>	 <20060726.230230.111423566.davem@davemloft.net>	 <20060727223931.GZ14627@postel.suug.ch>  <44C94529.5080605@trash.net> <1154078728.23563.21.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	jmorris@namei.org, netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53215 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1752009AbWG2BkQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 21:40:16 -0400
To: Martin Josefsson <gandalf@wlug.westbo.se>
In-Reply-To: <1154078728.23563.21.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Martin Josefsson wrote:
> As a somewhat related note, I've just digged a bit through RCU land,
> talked to dipankar and mckenney, and discovered that rcu_read_lock() /
> rcu_read_unlock() aren't strictly needed in softirqs since preempt is
> already disabled in softirqs. This means that you can use the result of
> the rcu read-side critical outside of the rcu_read_lock() /

Thats true, but in this case the code is executed both in softirq-
and user-context. Using rcu_read_lock and still relying on softirq
properties outside the locked section is also very confusing in my
opinion.

