From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] tunnel: use the correct endian for some fields
Date: Thu, 15 Nov 2012 09:08:21 -0800
Message-ID: <20121115090821.31b41e95@s6510.linuxnetplumber.net>
References: <1352969482-29836-1-git-send-email-amwang@redhat.com>
	<50A4AE82.3040602@6wind.com>
	<1352970275.31884.37.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36424 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1768440Ab2KORIY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 12:08:24 -0500
In-Reply-To: <1352970275.31884.37.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Nov 2012 17:04:35 +0800
Cong Wang <amwang@redhat.com> wrote:

> On Thu, 2012-11-15 at 09:57 +0100, Nicolas Dichtel wrote:
> > Le 15/11/2012 09:51, Cong Wang a =C3=A9crit :
> > > Fengguang reported:
> > >
> > > net/ipv6/ip6_tunnel.c:1571:33: sparse: incorrect type in assignme=
nt (different base types)
> > > net/ipv6/ip6_tunnel.c:1571:33:    expected restricted __be32 [use=
rtype] flowinfo
> > > net/ipv6/ip6_tunnel.c:1571:33:    got unsigned int
> > >
> > > for these fields, we need to use the correct endian wrapers.
> > >
> > > Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> > > Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> > > Cc: David S. Miller <davem@davemloft.net>
> > > Signed-off-by: Cong Wang <amwang@redhat.com>
> > Just one minute before my patch.
> > Your patch does not fix all warnings (i_flags & SIT_ISATAP in ip6_t=
unnel.c).
>=20
> Yeah, then ignore this patch. :)

i_flags is a mess right now, it mixed host and bigendian values in the
same field. Also SIT and VTI flags overlap.
