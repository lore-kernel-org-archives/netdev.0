From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next v2] ipv6: sysctl to restrict candidate source addresses
Date: Wed, 8 Jul 2015 10:29:20 +0900
Message-ID: <CAKD1Yr02efR=-PxKsR0nhpJyXJBSMmTvRctcJnoqqkfreUpAig@mail.gmail.com>
References: <1436151944-21072-1-git-send-email-ek@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Erik Kline <ek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:33058 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757484AbbGHB3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 21:29:41 -0400
Received: by oiyy130 with SMTP id y130so155232167oiy.0
        for <netdev@vger.kernel.org>; Tue, 07 Jul 2015 18:29:40 -0700 (PDT)
In-Reply-To: <1436151944-21072-1-git-send-email-ek@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 6, 2015 at 12:05 PM, Erik Kline <ek@google.com> wrote:
> Per RFC 6724, section 4, "Candidate Source Addresses":
>
>     It is RECOMMENDED that the candidate source addresses be the set
>     of unicast addresses assigned to the interface that will be used
>     to send to the destination (the "outgoing" interface).
>
> Add a sysctl to enable this behaviour.
>
> Signed-off-by: Erik Kline <ek@google.com>

I think this is useful, because it ensures that devices with a working
IPv6 configuration on interface A, and a partial IPv6 configuration on
interface B do not attempt to send packets on interface B using
interface A's source address.

Example: there are home routers in the wild that send out an IPv6
router advertisement that configures a default route but no IPv6
address. This change makes it so that the host does not attempt to use
an IPv6 address from another network (e.g., a cellular data
connection) on the home network.

It is also what the RFC recommends.

Acked-by: Lorenzo Colitti <lorenzo@google.com>
