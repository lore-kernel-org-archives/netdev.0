From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sockopt: Make SO_BINDTODEVICE readable
Date: Mon, 22 Oct 2012 23:52:18 +0200
Message-ID: <1350942738.8609.1375.camel@edumazet-glaptop>
References: <508123AC.5080208@parallels.com>  <50858ABD.2000206@hp.com>
	 <1350938702.8609.1299.camel@edumazet-glaptop>  <5085B8B0.6010500@hp.com>
	 <1350941831.8609.1355.camel@edumazet-glaptop>  <5085BF0A.2030602@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:33300 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756280Ab2JVVwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 17:52:23 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so978000eaa.19
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2012 14:52:21 -0700 (PDT)
In-Reply-To: <5085BF0A.2030602@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-22 at 17:47 -0400, Brian Haley wrote:
> On 10/22/2012 05:37 PM, Eric Dumazet wrote:
> > On Mon, 2012-10-22 at 17:20 -0400, Brian Haley wrote:
> > 
> >> It's not much different from what's there:
> >>
> >> 	setsockopt("foo");
> >>
> >> 	rename foo -> bar
> >>
> >> 	index = getsockopt();
> >> 	if_indextoname(index) -> "bar"
> >>
> >> I more raised the issue since you pass a 'char *' to setsockopt() but an 'int *'
> >> to getsockopt(), I don't think any other value is non-symmetrical like this.
> >>
> >> -Brian
> > 
> > I meant another cpu can be changing dev->name[] content while the
> > strcpy() is done, and you get a mangled devname, like "for" or "bao"
> > instead of "foo" or "bar"
> 
> Even when holding the rcu_read_lock()?  I'd have to hold the rtnl lock there?

Yes, rcu_read_lock() only makes sure the device doesnt disappear.

But its name can be changed.

You could use a seqcount_t, so that readers dont have to lock rtnl.

But do we really want to return a name here, I am not yet convinced.
