From: "Michael T Kerrisk" <mtk-lists@gmx.net>
Subject: Strangeness when write()-ing zero-length datagrams
Date: Mon, 9 Aug 2004 16:38:13 +0200 (MEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <19357.1092062293@www39.gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Godday,

On Linux 2.4.26 and 2.6.7, if we connect a datagram socket and=20
then use write() to send 0 bytes, a datagram is NOT generated=20
(this happens in both the Unix and Internet domains). =20
Datagrams are generated in this case for send() and sendto()=20
though. =20

As far as I can work out, this occurs because of the=20
following code in net/socket.c::sock_write/sock_aio_write():

    if(size=3D=3D0)        /* Match SYS5 behaviour */
        return 0;

Is the Linux behaviour intended?  It seems counterintuitive,=20
and it does not match what I see on other systems:

Solaris 8 does not behave like Linux in this case -=96 a zero=20
length datagram is sent and read by the receiver (tested for=20
Internet and Unix domain sockets).

Tru64 5.1 is the same as Solaris 8 (tested for Internet and=20
Unix domain sockets)

HP-UX 11 is the same as Solaris 8 (tested for Internet and=20
Unix domain sockets)

FreeBSD 4.9 and 5.1 are the same as Solaris 8 (tested for=20
Internet and Unix domain sockets)

Cheers,

Michael

--=20
Michael Kerrisk
mtk-lists@gmx.net

NEU: WLAN-Router f=FCr 0,- EUR* - auch f=FCr DSL-Wechsler!
GMX DSL =3D superg=FCnstig & kabellos http://www.gmx.net/de/go/dsl
