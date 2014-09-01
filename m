From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v3] lib/rhashtable: allow user to set the
 minimum shifts of shrinking
Date: Mon, 1 Sep 2014 10:03:02 +0100
Message-ID: <20140901090302.GB27933@casper.infradead.org>
References: <1409381306-7036-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:55939 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752785AbaIAJDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 05:03:06 -0400
Content-Disposition: inline
In-Reply-To: <1409381306-7036-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/30/14 at 02:48pm, Ying Xue wrote:
> Although rhashtable library allows user to specify a quiet big size
> for user's created hash table, the table may be shrunk to a
> very small size - HASH_MIN_SIZE(4) after object is removed from
> the table at the first time. Subsequently, even if the total amount
> of objects saved in the table is quite lower than user's initial
> setting in a long time, the hash table size is still dynamically
> adjusted by rhashtable_shrink() or rhashtable_expand() each time
> object is inserted or removed from the table. However, as
> synchronize_rcu() has to be called when table is shrunk or
> expanded by the two functions, we should permit user to set the
> minimum table size through configuring the minimum number of shifts
> according to user specific requirement, avoiding these expensive
> actions of shrinking or expanding because of calling synchronize_rcu(=
).
>=20
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

I see the following warning when compiling:

In file included from lib/rhashtable.c:17:0:
lib/rhashtable.c: In function =E2=80=98rhashtable_init=E2=80=99:
include/linux/kernel.h:715:17: warning: comparison of distinct pointer =
types lacks a cast [enabled by default]
  (void) (&_max1 =3D=3D &_max2);  \
                 ^
lib/rhashtable.c:570:22: note: in expansion of macro =E2=80=98max=E2=80=
=99
  params->min_shift =3D max(params->min_shift, ilog2(HASH_MIN_SIZE));
