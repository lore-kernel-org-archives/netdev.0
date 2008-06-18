From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: IPF Montvale machine panic when running a network-relevent
	testing
Date: Wed, 18 Jun 2008 13:12:02 +0800
Message-ID: <1213765922.25608.36.camel@ymzhang>
References: <1213345160.25608.3.camel@ymzhang>
	 <1213759663.25608.33.camel@ymzhang>
	 <20080617.203703.254889774.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-ia64-owner@vger.kernel.org>
In-Reply-To: <20080617.203703.254889774.davem@davemloft.net>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 2008-06-17 at 20:37 -0700, David Miller wrote:
> From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
> Date: Wed, 18 Jun 2008 11:27:43 +0800
>=20
> > This issue is caused by tcp defer accept. Mostly, process context c=
alls lock_sock
> > to apply a sleeping lock. BH (SoftIRQ) context calls bh_lock_sock(_=
nested) to just apply
> > for the sk->sk_lock.slock without sleeping, then do appropriate pro=
cessing based on
> > if sk->sk_lock.owned=3D=3D0. That works well if both process contex=
t and BH context operate
> > the same sk at the same time. But with =EF=BB=BFtcp defer accept, i=
t doesn't, because
> > process context(for example, in inet_csk_accept) locks the listen s=
k, while BH
> > context (in tcp_v4_rcv, for example) locks the child sk and calls
> > =EF=BB=BFtcp_defer_accept_check=EF=BB=BF =3D> inet_csk_reqsk_queue_=
add =3D> reqsk_queue_add, so there is a race
> > to access the listen sock.
> >=20
> > Below patch against 2.6.26-rc6 fixes the issue.
> >=20
> > =EF=BB=BF=EF=BB=BFSigned-off-by: Zhang Yanmin <yanmin.zhang@intel.c=
om>
>=20
> We reverted the guilty defer accept changes, please test Linus's
> current tree.
I happened to download git tree on June 16th, which includes the revert=
ing patch.

I confirm it fixes the hang issue.

-yanmin


--
To unsubscribe from this list: send the line "unsubscribe linux-ia64" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
