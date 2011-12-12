From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] kref: add function for reading kref value
Date: Mon, 12 Dec 2011 18:57:43 +0100
Message-ID: <1323712663.2583.16.camel@edumazet-laptop>
References: <1323693892-11570-1-git-send-email-dbaluta@ixiacom.com>
	 <20111212150255.GA7506@kroah.com>
	 <CAEnQRZBiVDAHH+uZ=Ugk=UP5qSvvMViGTM-bRWr+E27zivOUug@mail.gmail.com>
	 <1323703934.1765.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAEnQRZCZdPw9eWVmdvhtF7KCQkYpLMrkhv5qd5xYckxWksN+0w@mail.gmail.com>
	 <1323704494.1765.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAEnQRZAt0X6cxGLgLUVTB9rzLKVYLEnh=azS9WOyKAkUZEpj4g@mail.gmail.com>
	 <20111212173344.GA10162@kroah.com>
	 <CAEnQRZDFvD3BTJs45hvP8LVCF_SNrYZyxxiiGXXP+koFfaYAdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, adobriyan@gmail.com
To: Daniel Baluta <dbaluta@ixiacom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEnQRZDFvD3BTJs45hvP8LVCF_SNrYZyxxiiGXXP+koFfaYAdQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 12 d=C3=A9cembre 2011 =C3=A0 19:46 +0200, Daniel Baluta a =C3=A9=
crit :
> On Mon, Dec 12, 2011 at 7:33 PM, Greg KH <greg@kroah.com> wrote:
> > On Mon, Dec 12, 2011 at 06:42:59PM +0200, Daniel Baluta wrote:
> >> On Mon, Dec 12, 2011 at 5:41 PM, Eric Dumazet <eric.dumazet@gmail.=
com> wrote:
> >> > Le lundi 12 d=C3=A9cembre 2011 =C5=95 17:39 +0200, Daniel Baluta=
 a =C3=A9crit :
> >> >
> >> >> Ok, for the moment it seems to be a bad idea. But my intention =
is
> >> >> to integrate kref to networking code, and then to write a gener=
al
> >> >> debugging tool for refs.
> >> >>
> >> >> Tracking down reference count problems is hard, and this tool c=
an
> >> >> really help everyone.
> >> >
> >> > I dont think kref will help you that much, because its used ever=
ywhere.
> >> >
> >> > Adding a general debugging tool will provide too much noise.
> >> >
> >> > Instead, we (network dev) add debugging points where we want.
> >>
> >> Yes, but you have to do this each time you start debugging, for a
> >> particular referenced counted object.
> >>
> >> We must find a clever solution to avoid the noise. (e.g use
> >> /proc, /sysfs, /debugfs options to trigger dumping info for
> >> some/all objects with a certain state).
> >
> > Then use the dynamic debug infrastructure, which is there to help y=
ou
> > try to handle this type of debugging on-the-fly.
> >
> > But again, it's not a kref issue, sorry.
>=20
> I see. Thanks.
>=20
> One last remark: Should we encourage people
> to use kref implementation, instead of making
> their own ?
>=20
> What are the chances of accepting changes with
> respect to this?
>=20
> Just a few examples:
>=20
> neighbour.h
> 295:#define neigh_hold(n)	atomic_inc(&(n)->refcnt)
>=20
> addrconf.h
> 219:static inline void in6_dev_hold(struct inet6_dev *idev)
>=20

I dont know how to say this Daniel.

I dont think kref added layer is helping this. Just say no.

Since we convert about all network stack to RCU, we need much better ap=
i
than kref is offering.

(atomic_..._not_zero for example)
