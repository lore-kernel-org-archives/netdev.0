From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: [Bug #13339] rtable leak in ipv4/route.c
Date: Tue, 26 May 2009 01:28:34 +0200
Message-ID: <200905260128.35541.rjw@sisk.pl>
References: <ZPPBiNHr1LC.A.9ZH.K9bGKB@chimera> <uSztiUhmDDC.A.U8H.a9bGKB@chimera> <4A19CB7D.8000004@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Alexander V. Lukyanov" <lav-L+1EwoRT+D8@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4A19CB7D.8000004-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 25 May 2009, Eric Dumazet wrote:
> Rafael J. Wysocki a =C3=A9crit :
> > This message has been generated automatically as a part of a report
> > of recent regressions.
> >=20
> > The following bug entry is on the current list of known regressions
> > from 2.6.29.  Please verify if it still should be listed and let me=
 know
> > (either way).
> >=20
> >=20
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13339
> > Subject		: rtable leak in ipv4/route.c
> > Submitter	: Alexander V. Lukyanov <lav-L+1EwoRT+D8@public.gmane.org>
> > Date		: 2009-05-18 14:10 (7 days old)
> >=20
>=20
> Bug was present in 2.6.29, so its a regression from 2.6.28
>=20
> It is solved and available in David tree (net-2.6), and scheduled for=
 stable submission
>=20
> commit 1ddbcb005c395518c2cd0df504cff3d4b5c85853
> net: fix rtable leak in net/ipv4/route.c
>=20
> Alexander V. Lukyanov found a regression in 2.6.29 and made a complet=
e
> analysis found in http://bugzilla.kernel.org/show_bug.cgi?id=3D13339
> Quoted here because its a perfect one :
>=20
> begin_of_quotation
>  2.6.29 patch has introduced flexible route cache rebuilding. Unfortu=
nately the
>  patch has at least one critical flaw, and another problem.
>=20
>  rt_intern_hash calculates rthi pointer, which is later used for new =
entry
>  insertion. The same loop calculates cand pointer which is used to cl=
ean the
>  list. If the pointers are the same, rtable leak occurs, as first the=
 cand is
>  removed then the new entry is appended to it.
>=20
>  This leak leads to unregister_netdevice problem (usage count > 0).
>=20
>  Another problem of the patch is that it tries to insert the entries =
in certain
>  order, to facilitate counting of entries distinct by all but QoS par=
ameters.
>  Unfortunately, referencing an existing rtable entry moves it to list=
 beginning,
>  to speed up further lookups, so the carefully built order is destroy=
ed.
>=20
>  For the first problem the simplest patch it to set rthi=3D0 when rth=
i=3D=3Dcand, but
>  it will also destroy the ordering.
> end_of_quotation
>=20
> Problematic commit is 1080d709fb9d8cd4392f93476ee46a9d6ea05a5b
> (net: implement emergency route cache rebulds when gc_elasticity is e=
xceeded)
>=20
> Trying to keep dst_entries ordered is too complex and breaks the fact=
 that
> order should depend on the frequency of use for garbage collection.
>=20
> A possible fix is to make rt_intern_hash() simpler, and only makes
> rt_check_expire() a litle bit smarter, being able to cope with an arb=
itrary
> entries order. The added loop is running on cache hot data, while cpu
> is prefetching next object, so should be unnoticied.
>=20
> Reported-and-analyzed-by: Alexander V. Lukyanov <lav-L+1EwoRT+D8@public.gmane.org>
> Signed-off-by: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
> Acked-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

Thanks, updated.

Rafael
