From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 03/10] net: add IEEE 802.15.4 socket family implementation
Date: Thu, 4 Jun 2009 18:10:41 +0400
Message-ID: <bc64b4640906040710p5c7c941fi3341599bc3157b79@mail.gmail.com>
References: <1243868091-5315-1-git-send-email-dbaryshkov@gmail.com>
	 <1243868091-5315-2-git-send-email-dbaryshkov@gmail.com>
	 <1243868091-5315-3-git-send-email-dbaryshkov@gmail.com>
	 <1243868091-5315-4-git-send-email-dbaryshkov@gmail.com>
	 <20090603173214.6d3997f7.akpm@linux-foundation.org>
	 <20090604111634.GA28064@doriath.ww600.siemens.net>
	 <20090604134455.GB2839@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org,
	maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org, dmitry.baryshkov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	oliver.fendt-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090604134455.GB2839-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2009/6/4 John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>:
> On Thu, Jun 04, 2009 at 03:16:34PM +0400, Dmitry Eremin-Solenikov wro=
te:
>> On Wed, Jun 03, 2009 at 05:32:14PM -0700, Andrew Morton wrote:
>> > On Mon, =A01 Jun 2009 18:54:44 +0400
>> > Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
>> > > + switch (addr->addr_type) {
>> > > + case IEEE802154_ADDR_LONG:
>> > > + =A0 =A0 =A0 =A0 rtnl_lock();
>> > > + =A0 =A0 =A0 =A0 dev =3D dev_getbyhwaddr(net, ARPHRD_IEEE802154=
, addr->hwaddr);
>> > > + =A0 =A0 =A0 =A0 if (dev)
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_hold(dev);
>> > > + =A0 =A0 =A0 =A0 rtnl_unlock();
>> > > + =A0 =A0 =A0 =A0 break;
>> > > + case IEEE802154_ADDR_SHORT:
>> > > + =A0 =A0 =A0 =A0 if (addr->pan_id !=3D 0xffff && addr->short_ad=
dr !=3D IEEE802154_ADDR_UNDEF && addr->short_addr !=3D 0xffff) {
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct net_device *tmp;
>> > > +
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rtnl_lock();
>> > > +
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for_each_netdev(net, tmp) {
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tmp->type =
=3D=3D ARPHRD_IEEE802154) {
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 if (IEEE802154_MLME_OPS(tmp)->get_pan_id(tmp) =3D=3D addr->pan_id
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 && IEEE802154_MLME_OPS(tmp)->get_short_addr(tmp) =3D=3D addr->shor=
t_addr) {
>> >
>> > You must use very wide xterms :(
>>
>> ~120 chars in width :) =A0We prefer to have a single code line split=
 between
>> several screen lines, rather than split it manually in some weird pl=
aces
>> just to justify width of 80 chars.
>
> Hopefully you realize that many find this difficult to read -- I just
> can't spread my eyes far enough to comprehend the lines.
>
> 80 chars is not a hard limit, but it is a good goal. =A0120 is too wi=
de.

We do try to fit the lines into 80 chars, but when that seems logical.
I strongly dislike breaking comparations between lines.

--=20
With best wishes
Dmitry
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
