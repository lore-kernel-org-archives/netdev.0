From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/2] mISDN: Use time_before()
Date: Wed, 21 May 2014 13:07:46 -0700
Message-ID: <1400702866.11896.4.camel@joe-AO725>
References: <1400699406-31294-1-git-send-email-manuel.schoelling@gmx.de>
	 <537CFE29.7050100@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Manuel =?ISO-8859-1?Q?Sch=F6lling?= <manuel.schoelling@gmx.de>,
	isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <537CFE29.7050100@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-05-21 at 23:27 +0400, Sergei Shtylyov wrote:
> On 05/21/2014 11:10 PM, Manuel Sch=F6lling wrote:
> > To be future-proof and for better readability the time comparisons =
are modified
> > to use time_before() instead of plain, error-prone math.
> > diff --git a/drivers/isdn/mISDN/l1oip_core.c b/drivers/isdn/mISDN/l=
1oip_core.c
[]
> > @@ -287,7 +287,7 @@ l1oip_socket_send(struct l1oip *hc, u8 localcod=
ec, u8 channel, u32 chanmask,
> >   	p =3D frame;
> >
> >   	/* restart timer */
> > -	if ((int)(hc->keep_tl.expires-jiffies) < 5 * HZ) {
> > +	if (time_before(hc->keep_tl.expires - 5 * HZ, jiffies)) {
>=20
>     Wouldn't it be clearer this way:
>=20
> 	if (time_before(hc->keep_tl.expires, jiffies + 5 * HZ)) {

> >   		del_timer(&hc->keep_tl);
> >   		hc->keep_tl.expires =3D jiffies + L1OIP_KEEPALIVE * HZ;
> >   		add_timer(&hc->keep_tl);

mod_timer?
