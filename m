From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 4/6] vlan: Optimize multiple unregistration
Date: Thu, 29 Oct 2009 18:25:20 +0100
Message-ID: <4AE9D000.90603@trash.net>
References: <4AE728A9.2080209@gmail.com> <4AE8A425.1000600@trash.net> <4AE8ADE7.1010909@gmail.com> <4AE99C88.40403@trash.net> <4AE9A554.8030207@trash.net> <4AE9A6F6.5040209@gmail.com> <4AE9A7AA.70107@trash.net> <4AE9AA01.3020805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55308 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756478AbZJ2RZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 13:25:23 -0400
In-Reply-To: <4AE9AA01.3020805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Patrick McHardy a =E9crit :
>=20
>> Indeed, but unregister_vlan_dev() destroys the group once the
>> count has reached zero, so we must not access it after that.
>=20
> Well, I hoped call_rcu() callback doesnt fire and kfree(grp) until we=
 exited
> from unregister_vlan_dev_alls(), with RTNL locked...

The RTNL is a mutex, so it shouldn't prevent call_rcu from firing.
