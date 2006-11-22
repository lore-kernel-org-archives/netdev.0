From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Wed, 22 Nov 2006 13:44:16 +0300
Message-ID: <20061122104416.GD11480@2ka.mipt.ru>
References: <45564EA5.6020607@redhat.com> <20061113105458.GA8182@2ka.mipt.ru> <4560F07B.10608@redhat.com> <20061120082500.GA25467@2ka.mipt.ru> <4562102B.5010503@redhat.com> <20061121095302.GA15210@2ka.mipt.ru> <45633049.2000209@redhat.com> <20061121174334.GA25518@2ka.mipt.ru> <20061121184605.GA7787@2ka.mipt.ru> <4563FE71.4040807@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Alexander Viro <aviro@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:58556 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1162028AbWKVKqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Nov 2006 05:46:39 -0500
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <4563FE71.4040807@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 21, 2006 at 11:38:25PM -0800, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> >I've checked the code.
> >Since it will be a union, it is impossible to use _sigev_thread and =
it
> >becomes just SIGEV_SIGNAL case with different delivery mechanism.
> >Is it what you want?
>=20
> struct sigevent is defined like this:
>=20
> typedef struct sigevent {
>         sigval_t sigev_value;
>         int sigev_signo;
>         int sigev_notify;
>         union {
>                 int _pad[SIGEV_PAD_SIZE];
>                  int _tid;
>=20
>                 struct {
>                         void (*_function)(sigval_t);
>                         void *_attribute;       /* really pthread_att=
r_t */
>                 } _sigev_thread;
>         } _sigev_un;
> } sigevent_t;
>=20
>=20
> For the SIGEV_KEVENT case:
>=20
>   sigev_notify is set to SIGEV_KEVENT (obviously)
>=20
>   sigev_value can be used for the void* data passed along with the
>   signal, just like in the case of a signal delivery
>=20
> Now you need a way to specify the kevent descriptor.  Just add
>=20
>   int _kevent;
>=20
> inside the union and if you want
>=20
>   #define sigev_kevent_descr _sigev_un._kevent
>=20
> That should be all.

That what I implemented.
But in this case it will be impossible to have SIGEV_THREAD and SIGEV_K=
EVENT
at the same time, it will be just the same as SIGEV_SIGNAL but with
different delivery mechanism. Is is what you expect for that?

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View,=20
> CA =E2=9D=96

--=20
	Evgeniy Polyakov
