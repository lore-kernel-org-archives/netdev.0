From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [PATCH v2 net-next 2/2] tipc: add name distributor resiliency
 queue
Date: Tue, 26 Aug 2014 14:44:34 +0000
Message-ID: <A2BAEFC30C8FD34388F02C9B3121859D1C2BF752@eusaamb103.ericsson.se>
References: <1409043477-22761-1-git-send-email-erik.hugne@ericsson.com>
 <1409043477-22761-2-git-send-email-erik.hugne@ericsson.com>
 <20140826143245.GC24538@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>
To: Erik Hugne <erik.hugne@ericsson.com>,
	"ying.xue@windriver.com" <ying.xue@windriver.com>,
	Richard Alpe <richard.alpe@ericsson.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usevmg21.ericsson.net ([198.24.6.65]:52317 "EHLO
	usevmg21.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755253AbaHZOog convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 10:44:36 -0400
In-Reply-To: <20140826143245.GC24538@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(netdev removed from receiver list)

> -----Original Message-----
> From: Erik Hugne
> Sent: August-26-14 10:33 AM
> To: Jon Maloy; ying.xue@windriver.com; Richard Alpe;
> netdev@vger.kernel.org
> Cc: tipc-discussion@lists.sourceforge.net
> Subject: Re: [PATCH v2 net-next 2/2] tipc: add name distributor resil=
iency
> queue
>=20
> if (e->expiry > now) should in fact be
> if (time_after(e->expiry, now) to handle timer wraps correctly.
>=20
> Thanks Niklas S=F6derlund for pointing this out.
>=20
> v2 removed from patchwork
>=20
> //E

Also, don't use the version label an comment when you send this
to David. This has only relevance to us who are reviewing the
series. (I assume it was  a mistake)

///jon

>=20
> On Tue, Aug 26, 2014 at 10:57:57AM +0200, erik.hugne@ericsson.com wro=
te:
> > +void tipc_named_process_backlog(void) {
> > +	struct distr_queue_item *e, *tmp;
> > +	char addr[16];
> > +	u64 now =3D get_jiffies_64();
> > +
> > +	list_for_each_entry_safe(e, tmp, &tipc_dist_queue, next) {
> > +		if (e->expiry > now) {
> > +			if (!tipc_update_nametbl(&e->i, e->node, e-
> >dtype))
> > +				continue;
> > +		} else {
> > +			tipc_addr_string_fill(addr, e->node);
> > +			pr_warn_ratelimited("Dropping name table update
> (%d) of {%u, %u, %u} from %s key=3D%u\n",
> > +					    e->dtype, ntohl(e->i.type),
> > +					    ntohl(e->i.lower),
> > +					    ntohl(e->i.upper),
> > +					    addr, ntohl(e->i.key));
> > +		}
> > +		list_del(&e->next);
> > +		kfree(e);
> > +	}
> > +}
> > +
