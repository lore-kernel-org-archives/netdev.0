From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2] ipv6: sysctl to restrict candidate source
 addresses
Date: Wed, 08 Jul 2015 10:09:48 +0200
Message-ID: <1436342988.2928.9.camel@stressinduktion.org>
References: <1436151944-21072-1-git-send-email-ek@google.com>
	 <CAKD1Yr02efR=-PxKsR0nhpJyXJBSMmTvRctcJnoqqkfreUpAig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<hideaki.yoshifuji@miraclelinux.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Lorenzo Colitti <lorenzo@google.com>, Erik Kline <ek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:41981 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932693AbbGHIJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 04:09:52 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id EF7B020876
	for <netdev@vger.kernel.org>; Wed,  8 Jul 2015 04:09:51 -0400 (EDT)
In-Reply-To: <CAKD1Yr02efR=-PxKsR0nhpJyXJBSMmTvRctcJnoqqkfreUpAig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-07-08 at 10:29 +0900, Lorenzo Colitti wrote:
> On Mon, Jul 6, 2015 at 12:05 PM, Erik Kline <ek@google.com> wrote:
> > Per RFC 6724, section 4, "Candidate Source Addresses":
> > 
> >     It is RECOMMENDED that the candidate source addresses be the set
> >     of unicast addresses assigned to the interface that will be used
> >     to send to the destination (the "outgoing" interface).
> > 
> > Add a sysctl to enable this behaviour.
> > 
> > Signed-off-by: Erik Kline <ek@google.com>
> 
> I think this is useful, because it ensures that devices with a working
> IPv6 configuration on interface A, and a partial IPv6 configuration on
> interface B do not attempt to send packets on interface B using
> interface A's source address.
> 
> Example: there are home routers in the wild that send out an IPv6
> router advertisement that configures a default route but no IPv6
> address. This change makes it so that the host does not attempt to use
> an IPv6 address from another network (e.g., a cellular data
> connection) on the home network.
> 
> It is also what the RFC recommends.
> 
> Acked-by: Lorenzo Colitti <lorenzo@google.com>

I wonder a little bit, because addresses which match the outgoing
interface should get a higher score in saddr_eval, thus be automatically
preferred. Is this check not strong enough?

I really wonder if we can improve source address selection and make this
behavior a default without introducing a new sysctl.

Bye,
Hannes
