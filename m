From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] sockopt: Make SO_BINDTODEVICE readable
Date: Mon, 22 Oct 2012 22:58:23 +0100
Message-ID: <1350943103.2622.35.camel@bwh-desktop.uk.solarflarecom.com>
References: <508123AC.5080208@parallels.com>  <50858ABD.2000206@hp.com>
	 <1350938702.8609.1299.camel@edumazet-glaptop>  <5085B8B0.6010500@hp.com>
	 <1350941831.8609.1355.camel@edumazet-glaptop>  <5085BF0A.2030602@hp.com>
	 <1350942738.8609.1375.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:18087 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756260Ab2JVV61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 17:58:27 -0400
In-Reply-To: <1350942738.8609.1375.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-22 at 23:52 +0200, Eric Dumazet wrote:
> On Mon, 2012-10-22 at 17:47 -0400, Brian Haley wrote:
> > On 10/22/2012 05:37 PM, Eric Dumazet wrote:
> > > On Mon, 2012-10-22 at 17:20 -0400, Brian Haley wrote:
> > > 
> > >> It's not much different from what's there:
> > >>
> > >> 	setsockopt("foo");
> > >>
> > >> 	rename foo -> bar
> > >>
> > >> 	index = getsockopt();
> > >> 	if_indextoname(index) -> "bar"
> > >>
> > >> I more raised the issue since you pass a 'char *' to setsockopt() but an 'int *'
> > >> to getsockopt(), I don't think any other value is non-symmetrical like this.
> > >>
> > >> -Brian
> > > 
> > > I meant another cpu can be changing dev->name[] content while the
> > > strcpy() is done, and you get a mangled devname, like "for" or "bao"
> > > instead of "foo" or "bar"
> > 
> > Even when holding the rcu_read_lock()?  I'd have to hold the rtnl lock there?
> 
> Yes, rcu_read_lock() only makes sure the device doesnt disappear.
> 
> But its name can be changed.
> 
> You could use a seqcount_t, so that readers dont have to lock rtnl.
> 
> But do we really want to return a name here, I am not yet convinced.

If setsockopt() takes a name then it makes no sense that getsockopt()
would return an index.  Perhaps an SO_BINDTOIFINDEX would be useful, but
let's not make SO_BINDTODEVICE mean two different things.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
