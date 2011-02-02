From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for
 single TCP session balancing
Date: Wed, 02 Feb 2011 10:54:03 +0100
Message-ID: <4D4929BB.2000403@gmail.com>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru> <26330.1295049912@death> <4D35060D.5080004@intel.com> <4D358A47.4020009@yandex-team.ru> <4D35A9B4.7030701@gmail.com> <4D35B1B0.2090905@yandex-team.ru> <4D35BED5.7040301@gmail.com> <28837.1295382268@death> <4D370DC7.6000500@yandex-team.ru> <4D3745AF.5040808@gmail.com> <4D399062.3060004@yandex-team.ru> <19551.1296268113@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Oleg V. Ukhno" <olegu@yandex-team.ru>,
	John Fastabend <john.r.fastabend@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:41544 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706Ab1BBJyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 04:54:08 -0500
Received: by fxm20 with SMTP id 20so7815983fxm.19
        for <netdev@vger.kernel.org>; Wed, 02 Feb 2011 01:54:07 -0800 (PST)
In-Reply-To: <19551.1296268113@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 29/01/2011 03:28, Jay Vosburgh a =C3=A9crit :
> 	I've thought about this whole thing, and here's what I view as
> the proper way to do this.
>
> 	In my mind, this proposal is two separate pieces:
>
> 	First, a piece to make round-robin a selectable hash for
> xmit_hash_policy.  The documentation for this should follow the patte=
rn
> of the "layer3+4" hash policy, in particular noting that the new
> algorithm violates the 802.3ad standard in exciting ways, will result=
 in
> out of order delivery, and that other 802.3ad implementations may or =
may
> not tolerate this.
>
> 	Second, a piece to make certain transmitted packets use the
> source MAC of the sending slave instead of the bond's MAC.  This shou=
ld
> be a separate option from the round-robin hash policy.  I'd call it
> something like "mac_select" with two values: "default" (what we do no=
w)
> and "slave_src_mac" to use the slave's real MAC for certain types of
> traffic (I'm open to better names; that's just what I came up with wh=
ile
> writing this).  I believe that "certain types" means "everything but
> ARP," but might be "only IP and IPv6."  Structuring the option in thi=
s
> manner leaves the option open for additional selections in the future=
,
> which a simple "on/off" option wouldn't.  This option should probably
> only affect a subset of modes; I'm thinking anything except balance-t=
lb
> or -alb (because they do funky MAC things already) and active-backup =
(it
> doesn't balance traffic, and already uses fail_over_mac to control
> this).  I think this option also needs a whole new section down in th=
e
> bottom explaining how to exploit it (the "pick special MACs on slaves=
 to
> trick switch hash" business).
>
> 	Comments?

Looks really sensible to me.

I just propose the following option and option values : "src_mac_select=
" (instead of mac_select),=20
with "default" and "slave_mac" (instead of slave_src_mac) as possible v=
alues. In the future, we=20
might need a "dst_mac_select" option... :-)

Also, are there any risks that this kind of session load-balancing won'=
t properly cooperate with=20
multiqueue (as explained in "Overriding Configuration for Special Cases=
" in=20
Documentation/networking/bonding.txt)? I think it is important to ensur=
e we keep the ability to fine=20
tune the egress path selection

	Nicolas.
