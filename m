From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH net-next v3] net: remove delay at device dismantle
Date: Thu, 23 Aug 2012 12:33:03 +0800
Message-ID: <5035B27F.9060002@cn.fujitsu.com>
References: <1345691986.5904.40.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	maheshb@google.com, therbert@google.com, ebiederm@xmission.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:30032 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751589Ab2HWEcw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 00:32:52 -0400
In-Reply-To: <1345691986.5904.40.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B408=E6=9C=8823=E6=97=A5 11:19, Eric Dumazet =E5=86=
=99=E9=81=93:
> From: Eric Dumazet <edumazet@google.com>
>=20
> I noticed extra one second delay in device dismantle, tracked down to
> a call to dst_dev_event() while some call_rcu() are still in RCU queu=
es.
>=20
> These call_rcu() were posted by rt_free(struct rtable *rt) calls.
>=20
> We then wait a little (but one second) in netdev_wait_allrefs() befor=
e
> kicking again NETDEV_UNREGISTER.
>=20
> As the call_rcu() are now completed, dst_dev_event() can do the neede=
d
> device swap on busy dst.
>=20
> To solve this problem, add a new NETDEV_UNREGISTER_FINAL, called
> after a rcu_barrier(), but outside of RTNL lock.
>=20
> Use NETDEV_UNREGISTER_FINAL with care !
>=20
> Change dst_dev_event() handler to react to NETDEV_UNREGISTER_FINAL
>=20
> Also remove NETDEV_UNREGISTER_BATCH, as its not used anymore after
> IP cache removal.
>=20
> With help from Gao feng
>=20
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Mahesh Bandewar <maheshb@google.com>
> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> Cc: Gao feng <gaofeng@cn.fujitsu.com>

looks good to me, the lockdep warning message disappeared.
