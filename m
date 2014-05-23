From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH v3 0/8] net: ethernet: marvell: Assorted fixes
Date: Fri, 23 May 2014 17:01:27 -0300
Message-ID: <20140523200127.GA14290@arch.cereza>
References: <1400800023-1562-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <20140523.153616.2078296737930596480.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com,
	sebastian.hesselbarth@gmail.com,
	gregory.clement@free-electrons.com, alior@marvell.com,
	tawfik@marvell.com, andrew@lunn.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:56865 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751113AbaEWUCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 16:02:08 -0400
Content-Disposition: inline
In-Reply-To: <20140523.153616.2078296737930596480.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23 May 03:36 PM, David Miller wrote:
> From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
> Date: Thu, 22 May 2014 20:06:55 -0300
>=20
> > New round for this assorted fixes and clean-up series. There is mor=
e room for
> > clean-ups, and I'll start preparing more patches once these are acc=
epted.
> >=20
> > This series consists of cleanups and minor improvements on mvneta, =
mv643xx_eth
> > and mvmdio drivers. None of the patches imply any functionality cha=
nge, except
> > for the patch six "Change the number of default rx queues to one".
> >=20
> > This patch reduces the driver's allocated resources and makes the m=
ultiqueue
> > path in the poll function not get taken. The previous patchset cont=
ains more
> > details:
> >=20
> >   http://permalink.gmane.org/gmane.linux.network/315015
> >=20
> > As usual, any feedback on this will be well received!
>=20
> Series applied to net-next, but some comments:
>=20
> 1) Never use web sites to reference informative material, instead put=
 it
>    all explicitly into the commit message in your posting.
>=20
>    Web sites and archives come and go, the commit message is forever =
and
>    readily available to someone studying your changes.
>=20

OK, I'll keep this in mind.

> 2) Just get rid of that MVNETA_RX_POLL_WEIGHT and simply use the
>    generic default NAPI_POLL_WEIGHT which has the same value.
>=20
>    Any local NAPI weight selection must be done for a good reason and
>    be fully documented with performance metrics et al.
>=20

OK.

> 3) I know you inherited this, but the MTU change failure behavior is
>    not so great.  If the system is low on memory it could fail and lo=
sing
>    an interface completely during an MTU change is extremely poor beh=
avior.
>=20
>    I would suggest holding onto the old allocated TXQ resources, and
>    restoring them if the allocation of the new ones fail.
>=20
>    That way the MTU change itself would fail, but the interface would
>    remain up with the original MTU.
>=20
>    Please make sure that you properly revert the MTU adjustment in
>    this failure path.
>=20

Oh, I see. Thanks for the feedback, I'll take a look at this next week.
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
