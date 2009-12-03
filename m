From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH 3/4] llc: use a device based hash table to speed up multicast delivery
Date: Fri, 4 Dec 2009 01:30:54 +0200
Message-ID: <200912040130.54966.opurdila@ixiacom.com>
References: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com> <1259879498-27860-4-git-send-email-opurdila@ixiacom.com> <4B1842EE.7030208@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:8571 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753931AbZLCXeD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 18:34:03 -0500
In-Reply-To: <4B1842EE.7030208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 04 December 2009 00:59:58 you wrote:
> Octavian Purdila a =E9crit :
> > This patch adds a per SAP device based hash table to solve the
> > multicast delivery scalability issues for the case where the are a
> > large number of interfaces and a large number of sockets (bound to =
the
> > same SAP) are used.
> >
> > Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> > ---
> >  include/net/llc.h      |   20 ++++++++++++++++----
> >  include/net/llc_conn.h |    1 +
> >  net/llc/llc_conn.c     |   18 +++++++++++++++++-
> >  net/llc/llc_core.c     |    3 +++
> >  net/llc/llc_sap.c      |   11 ++++++-----
> >  5 files changed, 43 insertions(+), 10 deletions(-)
> >
> > diff --git a/include/net/llc.h b/include/net/llc.h
> > index 7940da1..31e9902 100644
> > --- a/include/net/llc.h
> > +++ b/include/net/llc.h
> > @@ -31,6 +31,14 @@ struct llc_addr {
> >  #define LLC_SAP_STATE_INACTIVE	1
> >  #define LLC_SAP_STATE_ACTIVE	2
> >
> > +#define LLC_SK_DEV_HASH_BITS 10
> > +#define LLC_SK_DEV_HASH_ENTRIES (1<<LLC_SK_DEV_HASH_BITS)
> > +
> > +struct llc_sk_list {
> > +	rwlock_t lock;
> > +	struct hlist_head list;
> > +};
> > +
>=20
> This patch introduces a big hash table, and 1024 rwlocks, for IXIACOM=
 need.
>=20

Yes, that is probably not appropriate for upstream. What would be a goo=
d=20
value?

> Is the problem both on lock contention and lookup ?

Since at this point we are using UP ports contention is not really an i=
ssue=20
for us. I've extrapolated this (lock per hash bucket) based on how lock=
ing is=20
done in other places, like UDP.=20
