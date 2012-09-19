From: Dave Jones <davej@redhat.com>
Subject: Re: kernel BUG at kernel/timer.c:748!
Date: Wed, 19 Sep 2012 17:10:59 -0400
Message-ID: <20120919211059.GA10985@redhat.com>
References: <20120905043523.GA12988@redhat.com>
 <alpine.LFD.2.00.1209052343110.2201@ja.ssi.bg>
 <20120914212958.GA25053@redhat.com>
 <CAK6E8=cAOTqOzrzWCG=_wcQkWKS4bKh1HJ0UAH2vJNqvDPh+GQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8372 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751942Ab2ISVLO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 17:11:14 -0400
Content-Disposition: inline
In-Reply-To: <CAK6E8=cAOTqOzrzWCG=_wcQkWKS4bKh1HJ0UAH2vJNqvDPh+GQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 15, 2012 at 11:16:52AM -0700, Yuchung Cheng wrote:
 > On Fri, Sep 14, 2012 at 2:29 PM, Dave Jones <davej@redhat.com> wrote:
 > > On Wed, Sep 05, 2012 at 11:48:29PM +0300, Julian Anastasov wrote:
 > >
 > >  > > kernel BUG at kernel/timer.c:748!
 > >  > > Call Trace:
 > >  > >  ? lock_sock_nested+0x8d/0xa0
 > >  > >  sk_reset_timer+0x1c/0x30
 > >  > >  ? sock_setsockopt+0x8c/0x960
 > >  > >  inet_csk_reset_keepalive_timer+0x20/0x30
 > >  > >  tcp_set_keepalive+0x3d/0x50
 > >  > >  sock_setsockopt+0x923/0x960
 > >  > >  ? trace_hardirqs_on_caller+0x16/0x1e0
 > >  > >  ? fget_light+0x24c/0x520
 > >  > >  sys_setsockopt+0xc6/0xe0
 > >  > >  system_call_fastpath+0x1a/0x1f
 > >  >
 > >  >      Can this help? In case you see ICMPV6_PKT_TOOBIG...
 > >  >
 > >  > [PATCH] tcp: fix possible socket refcount problem for ipv6
 > >
 > > I just managed to reproduce this bug on rc5 with this patch,
 > > so it doesn't seem to help.
 > Could you post some tcpdump traces?

It's likely that there aren't any packets.  The fuzzer isn't smart
enough (yet) to do anything too clever to the sockets it creates.

More likely is that this is some race where thread A is doing a setsockopt
while thread B is doing a tear-down of the same socket.

	Dave
