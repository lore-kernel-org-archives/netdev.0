From: NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
Date: Sat, 30 Jul 2011 09:30:25 +1000
Message-ID: <20110730093025.716f3f50@notabene.brown>
References: <20110729153207.17af3085@notabene.brown>
	<4E324DB4.7060600@fastmail.fm>
	<1311921035.7845.10.camel@edumazet-laptop>
	<4E3258E1.6020000@fastmail.fm>
	<20110729103634.GA12050@infradead.org>
	<5933F48C-49D6-492D-AB7B-B76A3ADDB6C6@fastmail.fm>
	<1311941491.2843.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<F67B6E82-9FA8-464E-B3FB-DC0D4EC18BB0@fastmail.fm>
	<20110729164836.GL23194@fieldses.org>
	<20110729165345.GM23194@fieldses.org>
	<F562C6F4-3FC2-4952-A903-8E87E9EF2D9D@fastmail.fm>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Greg Banks <gnb-97jfqw80gc6171pxa8y+qA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <F562C6F4-3FC2-4952-A903-8E87E9EF2D9D-97jfqw80gc6171pxa8y+qA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 30 Jul 2011 06:34:44 +1000 Greg Banks <gnb-97jfqw80gc6171pxa8y+qA@public.gmane.org> wrote:

>=20
>=20
> Sent from my iPhone
>=20
> On 30/07/2011, at 2:53, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> wrot=
e:
>=20
> > On Fri, Jul 29, 2011 at 12:48:36PM -0400, bfields wrote:
> >> On Fri, Jul 29, 2011 at 11:30:05PM +1000, Greg Banks wrote:
> >>>
> >>>
> >>> Sent from my iPhone
> >>>
> >>> On 29/07/2011, at 22:11, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> =20
> >>> wrote:
> >>>
> >>>> Le vendredi 29 juillet 2011 =E0 21:58 +1000, Greg Banks a =E9cri=
t :
> >>>>
> >>>>>
> >>>>> Sure, and a whole lot of the callsites are ("..._%d", cpu), =20
> >>>>> hence the
> >>>>> unfortune :(
> >>>>
> >>>> BTW, we could name nfsd threads differently :
> >>>>
> >>>> Currently, they all are named : "nfsd"
> >>>>
> >>>> If SVC_POOL_PERCPU is selected, we could name them :
> >>>> nfsd_c0 -> nfsd_cN
> >>>>
> >>>> If SVC_POOL_PERNODE is selected, we could name them :
> >>>> nfsd_n0  -> nfsd_nN
> >>>>
> >>>> That would help to check with "ps aux" which cpu/nodes are under
> >>>> stress.
> >>>>
> >>>>
> >>>
> >>> I like it!
> >>
> >> Yup, patch welcomed.--b.
> >
> > (Annoying fact: some initscripts stop nfsd using a rough equivalent=
 of
> > "killall nfsd".  So the name of the threads is arguably ABI.  I thi=
nk
> > those initscripts are nuts and deserve what they get, but that may =
be
> > because I'm forgetting the reason they do that.)
> >
>=20
> We had this discussion in May-June 2008; it's because the nfsds were =
=20
> once  many many years ago userspace threads.

Even when they became kernel threads, 'kill' was the only way to kill t=
hem -
at first.

>=20
> The "killall nfsd" semantics in those scripts are awful and lead to =20
> problems shutting down when there are lots of threads. It would =20
> probably be an improvement to provide a better shutdown mechanism and=
 =20
> force distros to use it.

rpc.nfsd 0

will stop all nfsd threads.  Follow with

  exportfs -f

and you should be done.  I'm not 100% sure about the nfsv4 thread thoug=
h -
would need to check.

And yes - I would love it if distros could standardise on start/stop sc=
ripts
so upstreams could maintain them sensibly.  This is my personal number =
1
reason for liking systemd - it pushes for this standardisation.

>=20
> Or, you could preserve the effective semantics by having a single =20
> "nfsd" thread whose purpose is to notice that it's being signalled an=
d =20
> perform a clean shutdown (perhaps blocking the thread doing the kill(=
) =20
> call until the shutdown has completed).

That's kinda neat.  It would be an ugly wart to have to keep around, bu=
t
sometimes that the price we pay for "no regressions".

NeilBrown
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
