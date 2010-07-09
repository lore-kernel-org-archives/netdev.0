From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.35-rc4-git3: Reported regressions from 2.6.34
Date: Thu, 08 Jul 2010 23:20:28 -0700 (PDT)
Message-ID: <20100708.232028.15247875.davem@davemloft.net>
References: <AANLkTiknnzWyVpqnPCpyiEVHLgkewd0zaGzLInABRe2G@mail.gmail.com>
	<20100708.213420.112614033.davem@davemloft.net>
	<1278653334.2435.196.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: torvalds@linux-foundation.org, rjw@sisk.pl,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, kaber@trash.net, jengelh@medozas.de,
	casteyde.christian@free.fr
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1278653334.2435.196.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 09 Jul 2010 07:28:54 +0200

> Le jeudi 08 juillet 2010 =E0 21:34 -0700, David Miller a =E9crit :
>> From: Linus Torvalds <torvalds@linux-foundation.org>
>> Date: Thu, 8 Jul 2010 18:34:25 -0700
>>=20
>> > On Thu, Jul 8, 2010 at 4:33 PM, Rafael J. Wysocki <rjw@sisk.pl> wr=
ote:
>> >>
>> >> Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D16=
187
>> >> Subject         : Carrier detection failed in dhcpcd when link is=
 up
>> >> Submitter       : Christian Casteyde <casteyde.christian@free.fr>
>> >> Date            : 2010-06-12 15:15 (27 days old)
>> >> First-Bad-Commit: http://git.kernel.org/linus/10708f37ae729baba9b=
67bd134c3720709d4ae62
>> >> Handled-By      : Andrew Morton <akpm@linux-foundation.org>
>> >=20
>> > David? This bisects to a networking commit. Doesn't look sensible,=
 but
>> > what do I know?
>>=20
>> My suspicion is that dhcpd uses netlink to dump the info of the
>> available links, and due to some bug gets confused with the new 64-b=
it
>> statistic netlink attribute being there now.
>> a second to have a look at this.
>=20
> It could be a dhcpcd bug because of extended size of answer
>=20
> According to strace, dhcpcd tries a recvmsg() call with
> a 256 bytes buffer to hold answer.
>=20
> Looking at current dhcpcd source, I confirm it cannot realloc its buf=
fer
 ...
> This program needs to fix this.

Agreed, I don't there is any reasonable way we could cater to this
application bug with some compatability bits.  Restricting the link
dump to 256 bytes is just too much inflexibility.

If NetworkManager can get this right, dhcpd very well can too :-)
