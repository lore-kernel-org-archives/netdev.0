From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: [RFC] How to implement wccp over gre tunnel ?
Date: Fri, 25 Jun 2004 01:00:41 +0200 (CEST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0406250044080.25930-100000@filer.marasystems.com>
References: <20040624194039.GA19574@stingr.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	<linux-net@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: Paul P Komkoff Jr <i@stingr.net>
In-Reply-To: <20040624194039.GA19574@stingr.net>
List-Id: netdev.vger.kernel.org

On Thu, 24 Jun 2004, Paul P Komkoff Jr wrote:

> Currently my goal is to make squid + wccp configuration working
> out-of-the box. Ideally - without any extra modules.

This is possible with WCCPv2 using direct routing avoiding the need of
GRE/WCCP tunneling. WCCPv2 patches do exists for Squid-2.5, but may be =
a
little hard to find.. (no official maintainer of the WCCPv2 support for
Squid at the moment)

> Currently, most wccp configurations are working with this module:
> http://www.squid-cache.org/WCCP-support/Linux/ip_wccp.c

Please note that this module is by no means clean, and lacks a lot in=20
security.

There is also a WCCP patch available to the GRE driver. This approach=20
provides a little more security but is also more complex to set up for =
the=20
same reasons and is not used very much..

  http://www.swelltech.com/pengies/joe/patches/linux-2.4.8-ip_gre.patch

The GRE patch is very simplistic and would do good of being properly=20
implemented and integrated with the "ip tunnel" command for=20
configuration of the GRE protocol (normal GRE / WCCPv1 / WCCPv2 /=20
whatever...).

> What do you think? Which way I should do?

I think approach 1 (decapsulation within GRE) is most suitable. It also=
=20
provides an adequate level of control on security and permissions which=
=20
may be hard to accomplish if separating the two.

Regards
Henrik Nordstr=F6m
aka hno@squid-cache.org and current maintainer of the Squid ip_wccp.c=20
module

