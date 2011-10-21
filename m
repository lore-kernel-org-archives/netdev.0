From: Kim Phillips <kim.phillips@freescale.com>
Subject: Re: IPsec performance bug
Date: Fri, 21 Oct 2011 12:54:29 -0500
Message-ID: <20111021125429.c84610ac.kim.phillips@freescale.com>
References: <20111019212229.72078d51.kim.phillips@freescale.com>
	<CAAM7YAkxP06_=y1wg4P1JhPDWhZgRM6+wbFQRG5PFkAq8vgsTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<hirofumi@mail.parknet.co.jp>
To: "Yan, Zheng" <zheng.z.yan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe003.messaging.microsoft.com ([216.32.181.183]:52186
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753333Ab1JURzX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Oct 2011 13:55:23 -0400
In-Reply-To: <CAAM7YAkxP06_=y1wg4P1JhPDWhZgRM6+wbFQRG5PFkAq8vgsTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Oct 2011 16:28:30 +0800
"Yan, Zheng" <zheng.z.yan@linux.intel.com> wrote:

> On Thu, Oct 20, 2011 at 10:22 AM, Kim Phillips
> <kim.phillips@freescale.com> wrote:
> > (b) any ideas how to fix? =A0I don't know much about routing
> > internals, but in ip_route_input_common(), if I remove the input
> > interface comparison (rth->rt_route_iif ^ iif), I get some
> > performance back, but the system becomes unstable (it's booted over
> > nfs).
>=20
> Looks like xfrm4_fill_dst() reset rt->rt_route_iif to 0, it makes the
> comparison (rth->rt_route_iif ^ iif) in
> ip_route_input_common() return false.
>=20
> Please try patch below. It improves the performance of 3.1-rc10
> kernel.

yes, thanks, ~50kpps performance is restored when applying this diff
to current net-next.

> (I'm not sure the patch is harmless)

the system appears to be more stable, but this is still concerning.

Kim
