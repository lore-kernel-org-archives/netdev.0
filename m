From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [GIT PATCH net-2.6.23] IPV6: Configurable IPv6 address
 selection policy table (RFC3484)
Date: Sun, 29 Apr 2007 12:02:18 -0700 (PDT)
Message-ID: <20070429.120218.115910157.davem@davemloft.net>
References: <20070419.162856.20840698.yoshfuji@linux-ipv6.org>
	<20070428.231707.39159334.davem@davemloft.net>
	<46343D9A.8010201@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: drepper@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46360
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754418AbXD2TCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2007 15:02:21 -0400
In-Reply-To: <46343D9A.8010201@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Drepper <drepper@redhat.com>
Date: Sat, 28 Apr 2007 23:39:22 -0700

> David Miller wrote:
> > One idea is to have glibc have some kind of socket open, subscribed
> > to a group which gets "sticky" events.
> 
> I don't quite yet know the context but I have to intervene: keeping
> sockets open is not good.  This will only cause problems.
> 
> Any interface must be memory based.  Something like "register a word
> which is set when an event arrives" is a much better interface.  Who you
> then go and retrieve messages is another issue.  If this is a rare event
> then opening is new netlink socket is no problem.

That's ne excellent point, however my concern is that we are
accumulating lots of these things.

You can't load up the vsyscall page with a memory word for each and
every thing of this nature, for example.

Something more scalable has to be used.
