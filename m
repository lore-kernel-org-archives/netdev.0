From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Iproute2 build broken by current kernel headers
Date: Tue, 10 Jan 2012 11:07:49 -0800
Message-ID: <20120110110749.42c1252a@nehalam.linuxnetplumber.net>
References: <20120110105409.3567bb1b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Emelyanov <xemul@parallels.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49438 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756667Ab2AJTHv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 14:07:51 -0500
In-Reply-To: <20120110105409.3567bb1b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Jan 2012 10:54:09 -0800
Stephen Hemminger <shemminger@vyatta.com> wrote:

> The update to inet diag broke compatibility with exported headers.
> Iproute2 uses sanitized kernel headers.
>=20
> gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -I../include -DRESOLV=
E_HOSTNAMES -DLIBDIR=3D\"/usr/lib/\"   -c -o ss.o ss.c
> ss.c: In function =E2=80=98tcp_show_netlink=E2=80=99:
> ss.c:1504:7: error: =E2=80=98struct inet_diag_req=E2=80=99 has no mem=
ber named =E2=80=98idiag_family=E2=80=99
> make[1]: *** [ss.o] Error 1

The structures need to be swapped to maintain source compatibility.
inet_diag_req_compat needs to be renamed back to inet_diag_req
inet_diag_req should be named something like inet_diag_req_generic
