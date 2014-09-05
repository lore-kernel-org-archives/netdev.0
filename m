From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch net] ipv6: restore the behavior of ipv6_sock_ac_drop()
Date: Sat, 06 Sep 2014 01:07:18 +0200
Message-ID: <1409958438.1201419.164224805.20ACC638@webmail.messagingengine.com>
References: <1409952780-24471-1-git-send-email-xiyou.wangcong@gmail.com>
 <1409955985.1192797.164218289.4192DDA7@webmail.messagingengine.com>
 <CAHA+R7N+WGNV5yTQ_hVbn-ez4Ar9395HzOGUU4tG9uLHqFPndA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Sabrina Dubroca <sd@queasysnail.net>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:50799 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752041AbaIEXHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 19:07:19 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by gateway2.nyi.internal (Postfix) with ESMTP id BC047209C9
	for <netdev@vger.kernel.org>; Fri,  5 Sep 2014 19:07:18 -0400 (EDT)
In-Reply-To: <CAHA+R7N+WGNV5yTQ_hVbn-ez4Ar9395HzOGUU4tG9uLHqFPndA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 6, 2014, at 00:41, Cong Wang wrote:
> On Fri, Sep 5, 2014 at 3:26 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > Hi Cong,
> >
> > Just doing normal review, really no bad intentions, just technical
> > follow-up. ;)
> 
> I believe you are not supposed to do it since definitely you
> said you don't want to work with me. You said it, not me,
> I respect any of your choice. :)

Oh no, you misunderstood me (maybe my bad). My only critique was that
you could have stated that you also saw a problem with the ENODEV return
before the patch was looked at by David.
Sure, let's forget that and work together.

> > On Fri, Sep 5, 2014, at 23:33, Cong Wang wrote:
> >> It is possible that the interface is already gone after joining
> >> the list of anycast on this interface as we don't hold a refcount
> >> for the device, in this case we are safe to ignore the error.
> >
> > anycast code actually inserts routes into the routing table and holds a
> > reference on the interface while that route is active.
> 
> But route could be deleted.

The routes are managed by the inet6_dev and it will drop the routes on
interface shutdown, correct. There is no strong reference from socket to
the routing entry. Only deleting a route should not work as it will
still be referenced by the anycast list in inet6_dev (though it won't
get used anymore).

> >> What's more important, for API compatibility we should not
> >> change this behavior for applications even if it were correct.
> >
> > IMHO adding new error codes never breaks existing applications because
> > there is no way they can explore all possible errno variables. Also we
> > already report ENODEV from multicast setsockopts. So I think it would be
> > ok to leave it as is, but I have no strong opinion on that and it would
> > be ok by me if the patch got accepted (maybe update the changelog).
> >
> 
> Again, too late to change, the code has been there since the beginning
> of git history. You should have a strong argument if you want to change
> it,
> otherwise restore old behavior, that is all. Obviously you don't even
> mention
> this when you accept that patch.

Let's settle this:
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Bye,
Hannes
