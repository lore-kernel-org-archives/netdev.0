From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 15:40:26 -0400
Message-ID: <1151696426.5270.224.camel@jzny2>
References: <1151623394.8922.27.camel@jzny2>
	 <20060629233933.GB14627@postel.suug.ch> <1151625826.8922.58.camel@jzny2>
	 <20060630004640.GC14627@postel.suug.ch> <1151629890.8922.121.camel@jzny2>
	 <20060630130811.GE14627@postel.suug.ch> <1151675843.5270.18.camel@jzny2>
	 <20060630141531.GG14627@postel.suug.ch> <1151678118.5270.45.camel@jzny2>
	 <20060630163229.GH14627@postel.suug.ch>
	 <20060630171348.GI14627@postel.suug.ch>  <44A55CF8.2040509@trash.net>
	 <1151688732.5270.101.camel@jzny2>  <44A56294.7030309@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:715 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932077AbWF3Tki
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 15:40:38 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FwOqy-0004l9-Pk
	for netdev@vger.kernel.org; Fri, 30 Jun 2006 15:40:36 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44A56294.7030309@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-30-06 at 19:42 +0200, Patrick McHardy wrote:
> jamal wrote:

> > Thomas makes the claim, this can be achieved only by using an ifindex.
> > And i havent been able to see how. I have a small performance problem if
> > i just use ifindex. Using ifindex will eventually save 32 bits on the
> > 64 bit machines. I posed the question as to which was more beneficial
> > as a solution that hasnt been addressed.
> 
> Are we still talking about this? Its easy: a pointer without taking
> a reference can become stale, 

I should have been clear: reference gets taken in mirred.

> with ifindex you do the lookup right
> when using it, so you either get an result or you don't. 

My arguement was:
dev get by index per device will involve a a) lookup + b) incrementing
the refcount. 
if i use the dev pointer in that path then it becomes only #b

in both cases, you need to increment the counter and then somewhere
decrement it.

cheers,
jamal

> It also
> saves atomic operations for anyone _not_ using it, which is that
> vast majority of users. So the patch clearly makes sense to me.



