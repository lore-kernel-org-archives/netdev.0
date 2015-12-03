From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] Improve Atheros ethernet driver not to do order 4
 GFP_ATOMIC allocation
Date: Thu, 3 Dec 2015 08:49:02 +0100
Message-ID: <20151203074902.GB4139@amd>
References: <20151127082010.GA2500@dhcp22.suse.cz>
 <20151128145113.GB4135@amd>
 <20151130132129.GB21950@dhcp22.suse.cz>
 <20151201.153517.224543138214404348.davem@davemloft.net>
 <CAMXMK6u1vQ772SGv-J3cKvOmS6QRAjjQLYiSiWO2+T=HRTiK1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>, mhocko@kernel.org, akpm@osdl.org,
	linux-kernel@vger.kernel.org, jcliburn@gmail.com,
	netdev@vger.kernel.org, rjw@rjwysocki.net, linux-mm@kvack.org,
	nic-devel@qualcomm.com, ronangeles@gmail.com, ebiederm@xmission.com
To: Chris Snook <chris.snook@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <CAMXMK6u1vQ772SGv-J3cKvOmS6QRAjjQLYiSiWO2+T=HRTiK1A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed 2015-12-02 22:43:31, Chris Snook wrote:
> On Tue, Dec 1, 2015 at 12:35 PM David Miller <davem@davemloft.net> wrot=
e:
>=20
> > From: Michal Hocko <mhocko@kernel.org>
> > Date: Mon, 30 Nov 2015 14:21:29 +0100
> >
> > > On Sat 28-11-15 15:51:13, Pavel Machek wrote:
> > >>
> > >> atl1c driver is doing order-4 allocation with GFP_ATOMIC
> > >> priority. That often breaks  networking after resume. Switch to
> > >> GFP_KERNEL. Still not ideal, but should be significantly better.
> > >
> > > It is not clear why GFP_KERNEL can replace GFP_ATOMIC safely neithe=
r
> > > from the changelog nor from the patch context.
> >
> > Earlier in the function we do a GFP_KERNEL kmalloc so:
> >
> > =C2=AF\_(=E3=83=84)_/=C2=AF
> >
> > It should be fine.
> >
>=20
> AFAICT, the people who benefit from GFP_ATOMIC are the people running a=
ll
> their storage over NFS/iSCSI who are suspending their machines while
> they're so busy they don't have any clean order 4 pagecache to drop, an=
d
> want the machine to panic rather than hang. The people who benefit
>from

iSCSI on machine that suspends... is that a joke or complicated way of
saying that noone benefits? And code uses... both GFP_ATOMIC and
GFP_KERNEL so that both sides are equally unhappy? :-).

Do you want to test the patch, update the subject line and send it to
Davem, or should I do it?

Do you see a way to split the allocation? Not even order 4 GFP_KERNEL
allocation is a nice thing to do...

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/b=
log.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
