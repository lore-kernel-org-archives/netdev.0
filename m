From: Michael Bellion and Thomas Heinz <nf@hipac.org>
Subject: Re: [ANNOUNCE] nf-hipac v0.8 released
Date: Wed, 2 Jul 2003 15:48:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307021548.19989.nf@hipac.org>
References: <Pine.LNX.4.44.0307020826530.23232-100000@netcore.fi> <200307021426.56138.nf@hipac.org> <3F02D964.7050301@draigBrady.com>
Reply-To: nf@hipac.org
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: P@draigbrady.com
In-Reply-To: <3F02D964.7050301@draigBrady.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi P=E1draig

> > Since real world network traffic always consists of a lot of differen=
t
> > sized packets taking maximum sized packets is very euphemistic. 1450 =
byte
> > packets at 950 Mbit/s correspond to approx. 80,000 packets/sec.
> > We are really interested in how our algorithm performs at higher pack=
et
> > rates. Our performance tests are based on 100 Mbit hardware so we cou=
dn't
> > test with more than approx. 80,000 packets/sec even with minimum size=
d
> > packets.
>
> Interrupt latency is the problem here. You'll require napi et. al
> to get over this hump.

Yes we know, but with 128 byte frame size you can archieve a packet rate =
of at=20
most 97,656 packets/sec (in theory) on 100 Mbit hardware. We don't think =
this=20
few more packets would have changed the results fundamentally, so it's=20
probably not worth it on 100 Mbit.
Certainly you are right, that napi is required on gigabit to saturate the=
 link=20
with small sized packets.=20

> Cool. The same sort of test with ordinary netfilter that
> I did showed it could only handle around 125 rules at this
> packet rate on a 1.4GHz PIII, e1000 @ 100Mb/s.
>
> # ./readprofile -m /boot/System.map | sort -nr | head -30
>    6779 total                                      0.0047
>    4441 default_idle                              69.3906
>     787 handle_IRQ_event                           7.0268
>     589 ip_packet_match                            1.6733
>     433 ipt_do_table                               0.6294
>     106 eth_type_trans                             0.5521
>     [...]

What do you want to show with this profile? Most of the time is spend in =
the=20
idle loop and in icq handling and only a few percentage in ip_packet_matc=
h=20
and ipt_do_table, so we don't quite get how this matches your statement=20
above. Could you explain this in a few words?

Regards,

+-----------------------+----------------------+
|   Michael Bellion     |     Thomas Heinz     |
| <mbellion@hipac.org>  |  <creatix@hipac.org> |
+-----------------------+----------------------+
