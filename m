From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next 0/7] net: introduce generic type and helpers
 for IP address
Date: Tue, 23 Jul 2013 10:26:37 +0800
Message-ID: <1374546397.24933.10.camel@cr0>
References: <1374476713-8838-1-git-send-email-amwang@redhat.com>
	 <1374525857.2061.57.camel@joe-AO722> <1374544823.24933.1.camel@cr0>
	 <1374545774.8308.5.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64396 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752015Ab3GWC0t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jul 2013 22:26:49 -0400
In-Reply-To: <1374545774.8308.5.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-22 at 19:16 -0700, Joe Perches wrote:
> On Tue, 2013-07-23 at 10:00 +0800, Cong Wang wrote:
> > On Mon, 2013-07-22 at 13:44 -0700, Joe Perches wrote:
> > > 
> > > I see no reason why vsprint's support for
> > > "struct sockaddr *" %pIS should be removed.
> > > 
> > > %pIS and %pIA can both exist.
> 
> > Because there is no need to keep both of them, struct sockaddr can be
> > safely converted to union inet_addr.
> 
> That's a bit fragile.
> The cost of keeping %pIS is pretty low.

I knew, but again, there is no need at all.

> 
> Also, if there is ever a check for %p<type>,
> then using:
> 
> 	struct sockaddr *foo = bar;
> 	...
> 	snprintf(buf, len, "%pIA", foo)
> 
> would need foo to be cast first to union inet_addr *
> 
> 	snprintf(buf, len, "%pIA", (union inet_addr *)foo);
> 
> 

You don't have to, compiler doesn't check the new specifier, and it is
safe even without any casting.

What's more, the existing %pIS user (sctp) is already converted to union
inet_addr, see patch 6/7.
