From: "Michael T Kerrisk" <mtk-lists@gmx.net>
Subject: Re: Strangeness when write()-ing zero-length datagrams
Date: Mon, 9 Aug 2004 17:59:00 +0200 (MEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <10578.1092067140@www39.gmx.net>
References: <20040809154057.GA30659@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bert,

> > On Linux 2.4.26 and 2.6.7, if we connect a datagram socket and=20
> > then use write() to send 0 bytes, a datagram is NOT generated=20
> > (this happens in both the Unix and Internet domains). =20
> > Datagrams are generated in this case for send() and sendto()=20
> > though.
>=20
> Some postings were made about this some time ago,=20

I didn't find anything with google or archive seach -- do
you have any more specific reference on this thread?

> it appears SUS has an
> opinion on zero byte writes:
>=20
> If nbyte is 0, write() will return 0 and have no other results if the=20
> file is a regular file; otherwise, the results are unspecified.
> http://www.opengroup.org/onlinepubs/007908799/xsh/write.html
>=20
> The send(2) manpage states:
>=20
> The send() function is identical to sendto() with a null pointer dest_l=
en
> argument, and to write() if no flags are used.
>=20
> Which means that a zero byte send() without flags is unspecified.

Yes, but on Linux write(fd, buf, 0) !=3D send(fd, buf, 0, 0), which
does seem inconsistent.  And as I noted, all the other implementations
I tested behave differently from Linux.

(Just so I'm sure we have our scenarios clear, I'm referring to=20
the following:

HOST-A                     HOST-B

create datagram socket

bind socket to=20
INADDR_ANY:port-x

                            create datagram socket

                            connect socket to=20
                            HOST-B:port-x

                            Now the following behave=20
                            differently:
                                write(fd, buf, 0);
                                send(fd, buf, 0, 0);

)

> Also note that it is hard if impossible to usefully inform userspace of
> the reception of a zery byte packet - returning 0 from recvfrom may=20
> also mean an 'orderly shutdown'.

Am I missing something?  There isn't the notion of a true=20
connection with datagram sockets, and so no notion of an orderly=20
shutdown (I am assuming you are meaning some scenario where the=20
peer calls shutdown() or close()).

It is straightforward to detect a zero-length datagram: recvfrom()
returns 0.

> Do you actually have a need for zero byte packets?

No, but I discovered this difference during some testing that I=20
was doing, and then observed that it seems different from=20
most (all?) other implementations.  It seemed worth documenting=20
this fact.

Cheers,

Michael

--=20
Michael Kerrisk
mtk-lists@gmx.net

NEU: WLAN-Router f=FCr 0,- EUR* - auch f=FCr DSL-Wechsler!
GMX DSL =3D superg=FCnstig & kabellos http://www.gmx.net/de/go/dsl
