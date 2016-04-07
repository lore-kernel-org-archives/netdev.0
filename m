From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next 5/7] sctp: reuse the some transport traversal
 functions in proc
Date: Thu, 7 Apr 2016 15:29:54 -0300
Message-ID: <20160407182954.GF15005@localhost.localdomain>
References: <cover.1459829123.git.lucien.xin@gmail.com>
 <cdc77cc7b894aab62dad372f0018c571e33cf16e.1459829123.git.lucien.xin@gmail.com>
 <20160407130930.GA4573@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>,
	linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	daniel@iogearbox.net, davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59670 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757271AbcDGS36 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 14:29:58 -0400
Content-Disposition: inline
In-Reply-To: <20160407130930.GA4573@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 07, 2016 at 09:09:30AM -0400, Neil Horman wrote:
> On Tue, Apr 05, 2016 at 12:06:30PM +0800, Xin Long wrote:
> > There are some transport traversal functions for sctp_diag, we can =
also
> > use it for sctp_proc. cause they have the similar situation to trav=
ersal
> > transport.
> >=20
> > Signed-off-by: Xin Long <lucien.xin@gmail.com>
> > ---
> >  net/sctp/proc.c | 80 +++++++++++++--------------------------------=
------------
> >  1 file changed, 18 insertions(+), 62 deletions(-)
> >=20
> > diff --git a/net/sctp/proc.c b/net/sctp/proc.c
> > index 5cfac8d..dd8492f 100644
> > --- a/net/sctp/proc.c
> > +++ b/net/sctp/proc.c
> > @@ -282,80 +282,31 @@ struct sctp_ht_iter {
> >  	struct rhashtable_iter hti;
> >  };
> > =20
> > -static struct sctp_transport *sctp_transport_get_next(struct seq_f=
ile *seq)
> > -{
> > -	struct sctp_ht_iter *iter =3D seq->private;
> > -	struct sctp_transport *t;
> > -
> > -	t =3D rhashtable_walk_next(&iter->hti);
> > -	for (; t; t =3D rhashtable_walk_next(&iter->hti)) {
> > -		if (IS_ERR(t)) {
> > -			if (PTR_ERR(t) =3D=3D -EAGAIN)
> > -				continue;
> > -			break;
> > -		}
> > -
> > -		if (net_eq(sock_net(t->asoc->base.sk), seq_file_net(seq)) &&
> > -		    t->asoc->peer.primary_path =3D=3D t)
> > -			break;
> > -	}
> > -
> > -	return t;
> > -}
> > -
>=20
> this may just be a nit, but you defined the new sctp_transport_get_ne=
xt in patch
> 2 of this series, and didn't remove this private version until here. =
 Is that
> going to cause some behavioral issue, if someone builds a kernel betw=
een patch 2

Yes, it causes issues:

=2E..net/sctp/proc.c:285:31: error: conflicting types for =E2=80=98sctp=
_transport_get_next=E2=80=99
 static struct sctp_transport *sctp_transport_get_next(struct seq_file =
*seq)
                               ^

> and 7?  Seems like perhaps those two patches should be merged.

Agreed.

  Marcelo
