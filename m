From: David Miller <davem@davemloft.net>
Subject: Re: Which one is chosen on multiple default gateway set?
Date: Wed, 22 Aug 2012 23:38:08 -0700 (PDT)
Message-ID: <20120822.233808.1184757734447108096.davem@davemloft.net>
References: <CAJPS4yY7sqqsOfhiouqjmfuW3Kof-ZzHEBs9E1+QoYYce01U4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org
To: daviseago@gmail.com
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <CAJPS4yY7sqqsOfhiouqjmfuW3Kof-ZzHEBs9E1+QoYYce01U4Q@mail.gmail.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Huang <daviseago@gmail.com>
Date: Thu, 23 Aug 2012 14:31:26 +0800

> If multiple default gateways are set, which one will be chosen? And if
> the chosen one is down, will others take over?

Yes.

> It works sometime, but not most of the time. (example below) The
> behavior is inconsistent.

The problem is that when a nexthop becomes unresponsive we need
to wait for an event to timeout the routing cache entry.

In 3.6.0-rc1 and later, this inconsistent behavior will happen less
often, because the routing cache has been removed so we will do the
full default route resolution on every route lookup.  The only problem
at that point is socket cached routes, those will still need to wait
for a timeout before the next default gateway will be tried.
