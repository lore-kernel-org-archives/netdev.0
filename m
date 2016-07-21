From: Shiraz Saleem <shiraz.saleem@intel.com>
Subject: Re: [PATCH V2] Add flow control to the portmapper
Date: Wed, 20 Jul 2016 21:47:50 -0500
Message-ID: <20160721024750.GA52712@ssaleem-MOBL4.amr.corp.intel.com>
References: <1468869810-64420-1-git-send-email-shiraz.saleem@intel.com>
 <20160719054006.GF20674@leon.nu>
 <20160719145024.GA69464@ssaleem-MOBL4.amr.corp.intel.com>
 <20160719173253.GL20674@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
	swise@opengridcomputing.com, e1000-rdma@lists.sourceforge.net,
	netdev@vger.kernel.org, Mustafa Ismail <mustafa.ismail@intel.com>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:45001 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752101AbcGUCrz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 22:47:55 -0400
Content-Disposition: inline
In-Reply-To: <20160719173253.GL20674@leon.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 19, 2016 at 08:32:53PM +0300, Leon Romanovsky wrote:
> On Tue, Jul 19, 2016 at 09:50:24AM -0500, Shiraz Saleem wrote:
> > On Tue, Jul 19, 2016 at 08:40:06AM +0300, Leon Romanovsky wrote:
> > >=20
> > > You are the one user of this new inline function.
> > > Why don't you directly call to netlink_unicast() in your ibnl_uni=
cast()
> > > without messing with widely visible header file?
> >=20
> > Since there is a non-blocking version of nlmsg_unicast(), the idea =
is=20
> > to make a blocking version available to others as well as maintain=20
> > consistency of existing code.
> >=20
>=20
> In such way, please provide patch series which will convert all other
> users to this new call.
>=20
> =E2=9E=9C  linux-rdma git:(master) grep -rI netlink_unicast * | grep =
-I 0
> kernel/audit.c: err =3D netlink_unicast(audit_sock, skb, audit_nlk_po=
rtid, 0);
> kernel/audit.c:         netlink_unicast(aunet->nlsk, skb, dest->porti=
d, 0);
> kernel/audit.c: netlink_unicast(aunet->nlsk , reply->skb, reply->port=
id, 0);
> kernel/audit.c: return netlink_unicast(audit_sock, skb, audit_nlk_por=
tid, 0);
> samples/connector/cn_test.c:    netlink_unicast(nls, skb, 0, 0);

These usages of netlink_unicast() with blocking are not the same as the=
 new
nlmsg_unicast_block() function. You can't drop in nlmsg_unicast_block()=
 in=20
place of netlink_unicast() in these places. I'm not going to introduce =
code=20
which modifies old behavior.
