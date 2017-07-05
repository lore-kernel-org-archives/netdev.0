From: "Reshetova, Elena" <elena.reshetova@intel.com>
Subject: Re: [PATCH 00/36] v2 net subsystem misc refcounter
	conversions
Date: Wed, 5 Jul 2017 09:03:06 +0000
Message-ID: <2236FBA76BA1254E88B949DDB74E612B6FF20D45@IRSMSX102.ger.corp.intel.com>
References: <1499172811-16271-1-git-send-email-elena.reshetova@intel.com>
	<20170704.230040.195111189904913382.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "peterz@infradead.org" <peterz@infradead.org>,
	"jchapman@katalix.com" <jchapman@katalix.com>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"jlayton@poochiereds.net" <jlayton@poochiereds.net>,
	"steffen.klassert@secunet.com" <steffen.klassert@secunet.com>,
	"zyan@redhat.com" <zyan@redhat.com>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"linux-x25@vger.kernel.org" <linux-x25@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"3chas3@gmail.com" <3chas3@gmail.com>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jreuter@yaina.de" <jreuter@yaina.de>,
	"keescook@chromium.org" <keescook@chromium.org>,
	"santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>,
To: David Miller <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170704.230040.195111189904913382.davem@davemloft.net>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


> From: Elena Reshetova <elena.reshetova@intel.com>
> Date: Tue,  4 Jul 2017 15:52:55 +0300
>=20
> > Changes in v2:
> >  * rebase on top of net-next
> >  * currently by default refcount_t =3D atomic_t (*) and uses all
> >    atomic standard operations unless CONFIG_REFCOUNT_FULL is enabled.
> >    This is a compromise for the systems that are critical on
> >    performance (such as net) and cannot accept even slight delay
> >    on the refcounter operations.
> >
> > This series, for various misc network components, replaces atomic_t ref=
erence
> > counters with the new refcount_t type and API (see include/linux/refcou=
nt.h).
> > By doing this we prevent intentional or accidental
> > underflows or overflows that can led to use-after-free vulnerabilities.
> > These are the last networking-related conversions with the exception of
> > network drivers (to be send separately).
> >
> > Please excuse the long patch set, but seems like breaking it up
> > won't save that much on CC list and most of the changes are
> > trivial.
> >
> > The patches are fully independent and can be cherry-picked separately.
> > In order to try with refcount functionality enabled in run-time,
> > CONFIG_REFCOUNT_FULL must be enabled.
> >
> > NOTE: automatic kernel builder for some reason doesn't like all my
> > network branches and regularly times out the builds on these branches.
> > Suggestion for "waiting a day for a good coverage" doesn't work, as
> > we have seen with generic network conversions. So please wait for the
> > full report from kernel test rebot before merging further up.
> > This has been compile-tested in 116 configs, but 71 timed out (includin=
g
> > all s390-related configs again). I am trying to see if they can fix
> > build coverage for me in meanwhile.
> >
> > * The respective change is currently merged into -next as
> >   "locking/refcount: Create unchecked atomic_t implementation".
>=20
> Series applied, that's enough for this cycle, please.

Thank you very much David! I really appreciate you taking so many of these =
conversions in
one go! I will stop for now :)=20

With regards to net, I only have networking drivers left (16 patches in tot=
al), but I can submit them in the
next round. Will go bug other subsystem maintainers next :)=20

Best Regards,
Elena.
