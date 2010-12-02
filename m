From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH][IPv6] Export userland ND options through netlink
 (RDNSS support)
Date: Thu, 02 Dec 2010 22:59:59 +0000
Message-ID: <1291330799.12031.134.camel@macbook.infradead.org>
References: <20071005060930.GA15305@via.ecp.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Pierre Ynard <linkfanel@yahoo.fr>, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38493 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757422Ab0LBXAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 18:00:04 -0500
In-Reply-To: <20071005060930.GA15305@via.ecp.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2007-10-05 at 08:09 +0200, Pierre Ynard wrote:
> As discussed before, this patch provides userland with a way to acces=
s
> relevant options in Router Advertisements, after they are processed a=
nd
> validated by the kernel. Extra options are processed in a generic way=
;
> this patch only exports RDNSS options described in RFC5006, but suppo=
rt
> to control which options are exported could be easily added.
>=20
> A new rtnetlink message type is defined, to transport Neighbor Discov=
ery
> options, along with optional context information. At the moment only
> the address of the router sending an RDNSS option is included, but
> additional attributes may be later defined, if needed by new use case=
s.

RFC5006 =C2=A76.1 says:
    Note:  An RDNSS address MUST be used only as long as both the RA
      router lifetime and the RDNSS option lifetime have not expired.
      The reason is that the RDNSS may not be currently reachable or ma=
y
      not provide service to the host's current address (e.g., due to
      network ingress filtering [16][17]).

But when this option makes its way to userspace, we don't *know* the RA
router lifetime, or even which interface it came in on. I'm not sure ho=
w
we can use this correctly.

This is a start at using it in ConnMan... but unless I'm missing
something, we don't have enough information to do it properly:
http://lists.connman.net/pipermail/connman/2010-December/002781.html

--=20
David Woodhouse                            Open Source Technology Centr=
e
David.Woodhouse@intel.com                              Intel Corporatio=
n

