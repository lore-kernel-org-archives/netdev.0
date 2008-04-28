From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH net-2.6/stable] [XFRM] AUDIT: Fix flowlabel text format.
Date: Mon, 28 Apr 2008 10:35:17 -0400
Message-ID: <1209393317.3093.2.camel@localhost.localdomain>
References: <20080427.122418.32604330.yoshfuji@linux-ipv6.org>
	<20080426.202558.208247674.davem@davemloft.net>
	<20080427.125437.59237838.yoshfuji@linux-ipv6.org>
	<200804281014.44318.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: YOSHIFUJI Hideaki / =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org,
	jmorris@namei.org, linux-audit@redhat.com, davem@davemloft.net
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <200804281014.44318.paul.moore@hp.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Mon, 2008-04-28 at 10:14 -0400, Paul Moore wrote:
> On Saturday 26 April 2008 11:54:37 pm YOSHIFUJI Hideaki / =E5=90=89=E8=97=
=A4=E8=8B=B1=E6=98=8E wrote:
> > [XFRM] AUDIT: Fix flowlabel text format ambibuity.
> >
> > Flowlabel text format was not correct and thus ambiguous.
> > For example, 0x00123 or 0x01203 are formatted as 0x123.
> > This is not what audit tools want.
> >
> > Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>=20
> Thanks for catching this.
>=20
> I'm CC'ing the audit list on this because they get nervous when people=20
> start changing the audit records.  However, I'll ack this patch because=
=20
> I think the previous behavior was incorrect and this should be=20
> considered a bugfix.
>=20
> Acked-by: Paul Moore <paul.moore@hp.com>

If you as the user of the audit system understand how that message is
being used its totally up to you to when it is safe and not safe to
change it.  I only get nervous when the audit system itself wants to
make/force changes to users of the subsystem.

Acked-by: Eric Paris <eparis@redhat.com>

-Eric


>=20
> > ---
> > diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> > index 5dcc10b..fac27ce 100644
> > --- a/net/xfrm/xfrm_state.c
> > +++ b/net/xfrm/xfrm_state.c
> > @@ -2112,7 +2112,7 @@ static void xfrm_audit_helper_pktinfo(struct
> > sk_buff *skb, u16 family, iph6 =3D ipv6_hdr(skb);
> >  		audit_log_format(audit_buf,
> >  				 " src=3D" NIP6_FMT " dst=3D" NIP6_FMT
> > -				 " flowlbl=3D0x%x%x%x",
> > +				 " flowlbl=3D0x%x%02x%02x",
> >  				 NIP6(iph6->saddr),
> >  				 NIP6(iph6->daddr),
> >  				 iph6->flow_lbl[0] & 0x0f,
>=20
