From: Patrick McManus <mcmanus@ducksong.com>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
	v2.6.26-rc3+
Date: Tue, 03 Jun 2008 22:54:52 -0400
Message-ID: <1212548093.12617.0.camel@tng>
References: <20080603094057.GA29480@elte.hu>
	 <Pine.LNX.4.64.0806032245490.3474@wrl-59.cs.helsinki.fi>
	 <Pine.LNX.4.64.0806040052270.3474@wrl-59.cs.helsinki.fi>
	 <20080603.150344.145518113.davem@davemloft.net>
	 <Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, mingo@elte.hu,
	peterz@infradead.org, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, rjw@sisk.pl,
	Andrew Morton <akpm@linux-foundation.org>, johnpol@2ka.mipt.ru
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from linode.ducksong.com ([64.22.125.164]:57545 "EHLO
	linode.ducksong.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752166AbYFDCyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 22:54:18 -0400
In-Reply-To: <Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-06-04 at 02:22 +0300, Ilpo J=C3=A4rvinen wrote:
=3D=3D
> --
> [PATCH] tcp DEFER_ACCEPT: fix racy access to listen_sk
>=20
> It seems that replacement of DA code also moved parts outside
> of appropriate locking. The Ingo's problem seems to come from
> the fact that two flows could now race in
> (inet_csk_)reqsk_queue_add corrupting the queue. ...This can
> leave dangling socks around which won't resolve themselves
> without stimuli from outside (e.g., external RST would help
> I think).


=EF=BB=BFIlpo, has anyone told you today that you rock? Well allow me -=
 you
rock.
>=20
do_rcv() clearly has the listening socket locked in the non-DA case, an=
d
in the DA case it is the 'child' ESTABLISHED socket that is locked -
leaving the accept queue unprotected. So simple.

-Pat


