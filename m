From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2] ipv6: sysctl to restrict candidate source
 addresses
Date: Wed, 08 Jul 2015 10:43:34 +0200
Message-ID: <1436345014.3846.11.camel@stressinduktion.org>
References: <1436151944-21072-1-git-send-email-ek@google.com>
	 <CAKD1Yr02efR=-PxKsR0nhpJyXJBSMmTvRctcJnoqqkfreUpAig@mail.gmail.com>
	 <1436342988.2928.9.camel@stressinduktion.org>
	 <CAKD1Yr1RMjQ=VD=V4Vr4gdUDa6_ZT62SEdKBSUP3PogQMRYyUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Erik Kline <ek@google.com>,
	=?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<hideaki.yoshifuji@miraclelinux.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:37795 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933657AbbGHIni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 04:43:38 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 8FC592083C
	for <netdev@vger.kernel.org>; Wed,  8 Jul 2015 04:43:37 -0400 (EDT)
In-Reply-To: <CAKD1Yr1RMjQ=VD=V4Vr4gdUDa6_ZT62SEdKBSUP3PogQMRYyUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-07-08 at 17:19 +0900, Lorenzo Colitti wrote:
> On Wed, Jul 8, 2015 at 5:09 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > I wonder a little bit, because addresses which match the outgoing
> > interface should get a higher score in saddr_eval, thus be 
> > automatically
> > preferred. Is this check not strong enough?
> 
> It isn't strong enough because the "prefer outgoing interface" rule is
> lower priority than other rules such as "prefer deprecated addresses"
> and "prefer matching scope".
> 
> For example, consider the case where you have an IPv6 default route
> but not an IPv6 address on one interface (e.g., wifi), and a working
> configuration (IPv6 default route and IPv6 address) on another
> interface (e.g., cellular data). In this situation, the host will send
> the packet out on the wifi interface using the source address from the
> the cellular interface to try to talk to wifi. This will not work
> because the wifi network will almost certainly drop the packet due to
> BCP-38 ingress filtering.

So in this case we report errors to user space instead of picking an
address from another interface. If we turn on this knob unconditionally
we cannot leave the set of possible source addresses empty, this will
change application behavior and admin habits too much, I fear.

> > I really wonder if we can improve source address selection and make 
> > this
> > behavior a default without introducing a new sysctl.
> 
> Another option I see is to change the behaviour to follow the RFC
> recommendation, and thus always use the matching interface. Is that a
> better option?
> 
> At the moment, we're going against the explicit recommendation of the
> RFC, and I don't see a good reason for that.

I really would like to come up with a sane works-always behavior for
this, but besides doing a retry on the complete source address selection
algorithm I currently cannot come up with an idea.

Maybe we can tweak saddr_eval a bit.

Thanks,
Hannes
