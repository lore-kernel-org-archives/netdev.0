From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] ipv6: basic implementation of reverse path
 filtering
Date: Mon, 06 Jun 2011 14:22:37 +0200
Message-ID: <1307362957.3098.7.camel@edumazet-laptop>
References: <1307360074-25473-1-git-send-email-eric@regit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Leblond <eric@regit.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54789 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756431Ab1FFMWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 08:22:41 -0400
Received: by wwa36 with SMTP id 36so3735701wwa.1
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2011 05:22:40 -0700 (PDT)
In-Reply-To: <1307360074-25473-1-git-send-email-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 juin 2011 =C3=A0 13:34 +0200, Eric Leblond a =C3=A9crit :
> This patch provides a basic implementation of reverse path filtering
> for IPv6. Functionnality can be activatedor desactivated through an
> rp_filter entry similar to the IPv4 one.
>=20
> The functionnality is disabled by default for backward compatibility
> but should be enable on all IPv6 routers/firewalls for security reaso=
n.
>=20
> This implementation is heavily based on the patch Denis Semmau propos=
ed
> in 2006.
>=20
> Signed-off-by: Eric Leblond <eric@regit.org>
> ---
>  include/linux/ipv6.h   |    2 ++
>  include/linux/sysctl.h |    1 +
>  net/ipv6/addrconf.c    |   10 ++++++++++
>  net/ipv6/ip6_output.c  |   32 ++++++++++++++++++++++++++++++++
>  4 files changed, 45 insertions(+), 0 deletions(-)
>=20

Hmm, is it matching ipv4 one really ?

vi +855 Documentation/networking/ip-sysctl.txt


rp_filter - INTEGER
        0 - No source validation.
        1 - Strict mode as defined in RFC3704 Strict Reverse Path
            Each incoming packet is tested against the FIB and if the i=
nterface
            is not the best reverse path the packet check will fail.
            By default failed packets are discarded.
        2 - Loose mode as defined in RFC3704 Loose Reverse Path
            Each incoming packet's source address is also tested agains=
t the FIB
            and if the source address is not reachable via any interfac=
e
            the packet check will fail.


