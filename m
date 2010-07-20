From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH 2/5] ixgbe: drop support for UDP in RSS
 hash generation
Date: Tue, 20 Jul 2010 08:39:40 +0200
Message-ID: <1279607980.2458.82.camel@edumazet-laptop>
References: <20100719235831.14112.14175.stgit@localhost.localdomain>
	 <20100719235925.14112.65890.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	bphilips@novell.com, Alexander Duyck <alexander.h.duyck@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42013 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755356Ab0GTGjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 02:39:44 -0400
Received: by wwj40 with SMTP id 40so379034wwj.1
        for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 23:39:43 -0700 (PDT)
In-Reply-To: <20100719235925.14112.65890.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 juillet 2010 =C3=A0 16:59 -0700, Jeff Kirsher a =C3=A9crit =
:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
>=20
> This change removes UDP from the supported protocols for RSS hashing.=
  The
> reason for removing this protocol is because IP fragmentation was cau=
sing a
> network flow to be broken into two streams, one for fragmented, and o=
ne for
> non-fragmented and this in turn was causing out-of-order issues.
>=20

Jeff, does it mean all UDP packets are going to be delivered to a singl=
e
queue ?

This would be a serious regression.

Many UDP applications try hard to not use fragments.=20

They are going to pay the price because some application :
- Use big segments, fragmented.
- Is subject to OOO artifacts.

We would like some clarifications please :)



