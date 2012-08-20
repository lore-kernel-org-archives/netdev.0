From: Dave Jones <davej@redhat.com>
Subject: Re: WARNING: at net/ipv4/tcp.c:1598 tcp_recvmsg+0x641/0xd30()
Date: Mon, 20 Aug 2012 12:20:50 -0400
Message-ID: <20120820162050.GA25593@redhat.com>
References: <20120806154616.GB2187@redhat.com>
 <20120810202910.GA19359@redhat.com>
 <1344631218.31104.2745.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30904 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752392Ab2HTQUy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2012 12:20:54 -0400
Content-Disposition: inline
In-Reply-To: <1344631218.31104.2745.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 10, 2012 at 10:40:18PM +0200, Eric Dumazet wrote:
 
 > >  >  > backtrace:
 > >  >  > :WARNING: at net/ipv4/tcp.c:1598 tcp_recvmsg+0x641/0xd30()
 > > 
 > > We're getting more reports of this happening too.
 > 
 > Might be a driver issue with LRO / GRO/ TCP coalescing
 > 
 > So we need a _lot_ of details.

I looked over all the existing reports of this. It's a bit of a mess.
It seems to affect multiple drivers.
A big problem is that the network stack seems to get in a really screwed up state
when this happens, and the automated bug filer files these corrupted traces.

A secondary problem is that because these are automated reports, not all users
are responsive to answer questions afterwards...

Anyway, what I've gathered so far..

3.4-rc	i2400m_usb      https://bugzilla.redhat.com/show_bug.cgi?id=807114

unknown (mangled traces) https://bugzilla.redhat.com/show_bug.cgi?id=841016

possibly e1000e (also mangled) https://bugzilla.redhat.com/show_bug.cgi?id=841769

3.4.4	unknown (mangled)	https://bugzilla.redhat.com/show_bug.cgi?id=849275
 (same guy, probably e1000e)	https://bugzilla.redhat.com/show_bug.cgi?id=849276

3.5.0	r8712u  https://bugzilla.redhat.com/show_bug.cgi?id=845853

3.5.0	unknown https://bugzilla.redhat.com/show_bug.cgi?id=846991


any ideas on any additional debug printk's we could add ?

	Dave
