From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] netlink: Increase netlink dump skb message size
Date: Mon, 25 Apr 2011 23:56:00 -0700 (PDT)
Message-ID: <20110425.235600.104065244.davem@davemloft.net>
References: <20110425220157.2012.96707.stgit@gitlad.jf.intel.com>
	<1303799597.2747.214.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gregory.v.rose@intel.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47763
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757059Ab1DZG4e convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2011 02:56:34 -0400
In-Reply-To: <1303799597.2747.214.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 26 Apr 2011 08:33:17 +0200

> Le lundi 25 avril 2011 =E0 15:01 -0700, Greg Rose a =E9crit :
>> The message size allocated for rtnl info dumps was limited to a sing=
le page.
>> This is not enough for additional interface info available with devi=
ces
>> that support SR-IOV.  Check that the amount of data allocated is suf=
ficient
>> for the amount of data requested.
>>=20
>> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
>> ---
>>=20
>>  include/linux/rtnetlink.h |    1 +
>>  net/core/rtnetlink.c      |    6 ++++++
>>  net/netlink/af_netlink.c  |   37 +++++++++++++++++++++++++++++++---=
---
>>  3 files changed, 38 insertions(+), 6 deletions(-)
>>=20
>=20
> Hmm, thats a hack, because netlink_dump() is generic and you add
> something very specific.

You also can't do this without breaking applications.

We've trained every single netlink library out there about this message=
 size
formula, so they know that if you allocate at least 8192 bytes for a re=
cvmsg()
call they can receive fully any single netlink message.

And they must be able to make assumptions like this, otherwise they
cannot know how to reliably be able to receive a netlink message in
it's entirety in a generic fashion.

So one must not attack this problem from this angle.

It is absolutely necessary to find some way to report the VF
information, out of band, instead of trying to make the message
larger.

Needing more than 8K to get a dump of a single device over netlink is
absolutely rediculious, this VF stuff was poorly designed.  If has to
be fixed and the current stuff marked deprecated.
