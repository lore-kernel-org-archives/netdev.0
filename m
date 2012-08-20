From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at net/ipv4/tcp.c:1598 tcp_recvmsg+0x641/0xd30()
Date: Mon, 20 Aug 2012 18:42:52 +0200
Message-ID: <1345480972.5158.330.camel@edumazet-glaptop>
References: <20120806154616.GB2187@redhat.com>
	 <20120810202910.GA19359@redhat.com>
	 <1344631218.31104.2745.camel@edumazet-glaptop>
	 <20120820162050.GA25593@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:60950 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392Ab2HTQm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 12:42:57 -0400
Received: by bkwj10 with SMTP id j10so1923570bkw.19
        for <netdev@vger.kernel.org>; Mon, 20 Aug 2012 09:42:55 -0700 (PDT)
In-Reply-To: <20120820162050.GA25593@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-20 at 12:20 -0400, Dave Jones wrote:
> On Fri, Aug 10, 2012 at 10:40:18PM +0200, Eric Dumazet wrote:
>  
>  > >  >  > backtrace:
>  > >  >  > :WARNING: at net/ipv4/tcp.c:1598 tcp_recvmsg+0x641/0xd30()
>  > > 
>  > > We're getting more reports of this happening too.
>  > 
>  > Might be a driver issue with LRO / GRO/ TCP coalescing
>  > 
>  > So we need a _lot_ of details.
> 
> I looked over all the existing reports of this. It's a bit of a mess.
> It seems to affect multiple drivers.
> A big problem is that the network stack seems to get in a really screwed up state
> when this happens, and the automated bug filer files these corrupted traces.
> 
> A secondary problem is that because these are automated reports, not all users
> are responsive to answer questions afterwards...
> 
> Anyway, what I've gathered so far..
> 
> 3.4-rc	i2400m_usb      https://bugzilla.redhat.com/show_bug.cgi?id=807114
> 
> unknown (mangled traces) https://bugzilla.redhat.com/show_bug.cgi?id=841016
> 
> possibly e1000e (also mangled) https://bugzilla.redhat.com/show_bug.cgi?id=841769
> 
> 3.4.4	unknown (mangled)	https://bugzilla.redhat.com/show_bug.cgi?id=849275
>  (same guy, probably e1000e)	https://bugzilla.redhat.com/show_bug.cgi?id=849276
> 
> 3.5.0	r8712u  https://bugzilla.redhat.com/show_bug.cgi?id=845853
> 
> 3.5.0	unknown https://bugzilla.redhat.com/show_bug.cgi?id=846991
> 
> 
> any ideas on any additional debug printk's we could add ?
> 
> 	Dave
> 


We had a generic bug in old kernels, so you might ignore too old
reports.

This was fixed in commit 1ca7ee30630e1022dbcf1b51be20580815ffab73
(tcp: take care of overlaps in tcp_try_coalesce())
