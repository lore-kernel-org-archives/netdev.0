From: Nagendra Tomar <tomer_iisc@yahoo.com>
Subject: Re: [PATCH 2.6.23-rc6 Resending] NETWORKING : Edge Triggered EPOLLOUT events get missed for TCP sockets
Date: Thu, 20 Sep 2007 01:02:51 -0700 (PDT)
Message-ID: <712722.8047.qm@web53708.mail.re2.yahoo.com>
References: <46F20F24.1020900@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Davide Libenzi <davidel@xmailserver.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757518AbXITID0@vger.kernel.org>
In-Reply-To: <46F20F24.1020900@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- Eric Dumazet <dada1@cosmosbay.com> wrote:

> Nagendra Tomar a =E9crit :
> > --- Davide Libenzi <davidel@xmailserver.org> wrote:
> >=20
> >> On Wed, 19 Sep 2007, David Miller wrote:
> >>
> >>> From: Nagendra Tomar <tomer_iisc@yahoo.com>
> >>> Date: Wed, 19 Sep 2007 15:37:09 -0700 (PDT)
> >>>
> >>>> With the SOCK_NOSPACE check in tcp_check_space(), this epoll_wai=
t call will=20
> >>>> not return, even when the incoming acks free the buffers.
> >>>>         Note that this patch assumes that the SOCK_NOSPACE check=
 in
> >>>> tcp_check_space is a trivial optimization which can be safely re=
moved.
> >>> I already replied to your patch posting explaining that whatever =
is
> >>> not setting SOCK_NOSPACE should be fixed instead.
> >>>
> >>> Please address that, thanks.
> >> You're not planning of putting the notion of a SOCK_NOSPACE bit in=
side a=20
> >> completely device-unaware interface like epoll, I hope?
> >>
> >=20
> > Definitely not !=20
> >=20
> > The point is that the "tcp write space available"=20
> > wakeup does not get called if SOCK_NOSPACE bit is not set. This was
> > fine when the wakeup was merely a wakeup (since SOCK_NOSPACE bit=20
> > indicated that someone really cared abt the wakeup). Now after the
> > introduction of callback'ed wakeups, we might have some work to
> > do inside the callback even if there is nobody interested in the wa=
keup
> > at that point of time.=20
> >=20
> > In this particular case the ep_poll_callback is not getting called =
and
> > hence the socket fd is not getting added to the ready list.
> >=20
>=20
> Does it means that with your patch each ACK on a ET managed socket wi=
ll=20
> trigger an epoll event   ?
>=20
> Maybe your very sensitive high throuput appication needs to set a fla=
g or=20
> something at socket level to ask for such a behavior.
>=20
> The default should stay as is. That is an event should be sent only i=
f someone=20
> cared about the wakeup.
>=20

A high throughput app will always care about the wakeup, or else it wil=
l=20
not be a high throughput app in the first place. An application that
occasionaly writes and then goes to slumber and then writes again will
not be a high throughput app.=20
   =20
My point is that the SOCK_NOSPACE check does not save us much. For
high throughput app it will almost always be set, thus making the=20
check insignificant, and for the low throughput case we care less.

Thanx,
Tomar



      ___________________________________________________________
Yahoo! Answers - Got a question? Someone out there knows the answer. Tr=
y it
now.
http://uk.answers.yahoo.com/=20
