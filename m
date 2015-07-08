From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next v2] ipv6: sysctl to restrict candidate source addresses
Date: Wed, 8 Jul 2015 17:19:49 +0900
Message-ID: <CAKD1Yr1RMjQ=VD=V4Vr4gdUDa6_ZT62SEdKBSUP3PogQMRYyUA@mail.gmail.com>
References: <1436151944-21072-1-git-send-email-ek@google.com>
 <CAKD1Yr02efR=-PxKsR0nhpJyXJBSMmTvRctcJnoqqkfreUpAig@mail.gmail.com> <1436342988.2928.9.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Erik Kline <ek@google.com>,
	=?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:33955 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935264AbbGHIUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 04:20:10 -0400
Received: by ykcp133 with SMTP id p133so14103802ykc.1
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 01:20:09 -0700 (PDT)
In-Reply-To: <1436342988.2928.9.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 8, 2015 at 5:09 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> I wonder a little bit, because addresses which match the outgoing
> interface should get a higher score in saddr_eval, thus be automatically
> preferred. Is this check not strong enough?

It isn't strong enough because the "prefer outgoing interface" rule is
lower priority than other rules such as "prefer deprecated addresses"
and "prefer matching scope".

For example, consider the case where you have an IPv6 default route
but not an IPv6 address on one interface (e.g., wifi), and a working
configuration (IPv6 default route and IPv6 address) on another
interface (e.g., cellular data). In this situation, the host will send
the packet out on the wifi interface using the source address from the
the cellular interface to try to talk to wifi. This will not work
because the wifi network will almost certainly drop the packet due to
BCP-38 ingress filtering.

> I really wonder if we can improve source address selection and make this
> behavior a default without introducing a new sysctl.

Another option I see is to change the behaviour to follow the RFC
recommendation, and thus always use the matching interface. Is that a
better option?

At the moment, we're going against the explicit recommendation of the
RFC, and I don't see a good reason for that.
