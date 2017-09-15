From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [PATCH net-next v1] bridge: also trigger RTM_NEWLINK when interface is released from bridge
Date: Fri, 15 Sep 2017 23:08:42 +0200
Message-ID: <m3zi9vbrfp.fsf@luffy.cx>
References: <20170915193808.22338-1-vincent@bernat.im>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:53140 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751628AbdIOVRJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 15 Sep 2017 17:17:09 -0400
In-Reply-To: <20170915193808.22338-1-vincent@bernat.im> (Vincent Bernat's
        message of "Fri, 15 Sep 2017 21:38:08 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 15 septembre 2017 21:38 +0200, Vincent Bernat <vincent@bernat.im=
>=C2=A0:

> Currently, when an interface is released from a bridge, we get a
> RTM_DELLINK event through netlink:
>
> Deleted 2: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 =
state UNKNOWN
>     link/ether 6e:23:c2:54:3a:b3

It should be noted this only happens when using the ioctl API. When
using the netlink API, rtnetlink.c will send a RTM_NEWLINK because of
the modification.
--=20
When in doubt, tell the truth.
		-- Mark Twain
