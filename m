From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Iproute2 build broken by current kernel headers
Date: Wed, 11 Jan 2012 10:24:00 -0800
Message-ID: <20120111102400.178baee6@nehalam.linuxnetplumber.net>
References: <20120110105409.3567bb1b@nehalam.linuxnetplumber.net>
	<20120110110749.42c1252a@nehalam.linuxnetplumber.net>
	<4F0D2D88.8010705@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59888 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754772Ab2AKSYF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2012 13:24:05 -0500
In-Reply-To: <4F0D2D88.8010705@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Jan 2012 10:34:48 +0400
Pavel Emelyanov <xemul@parallels.com> wrote:

> On 01/10/2012 11:07 PM, Stephen Hemminger wrote:
> > On Tue, 10 Jan 2012 10:54:09 -0800
> > Stephen Hemminger <shemminger@vyatta.com> wrote:
> >=20
> >> The update to inet diag broke compatibility with exported headers.
> >> Iproute2 uses sanitized kernel headers.
> >>
> >> gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -I../include -DRES=
OLVE_HOSTNAMES -DLIBDIR=3D\"/usr/lib/\"   -c -o ss.o ss.c
> >> ss.c: In function =E2=80=98tcp_show_netlink=E2=80=99:
> >> ss.c:1504:7: error: =E2=80=98struct inet_diag_req=E2=80=99 has no =
member named =E2=80=98idiag_family=E2=80=99
> >> make[1]: *** [ss.o] Error 1
> >=20
> > The structures need to be swapped to maintain source compatibility.
> > inet_diag_req_compat needs to be renamed back to inet_diag_req
> > inet_diag_req should be named something like inet_diag_req_generic
>=20
> Stephen, actually the diag modules were patched to be only binary com=
patible with the ss.
> In order to make it compile with new headers I've sent the patches fi=
xing ss, here they are:
>=20
> http://www.spinics.net/lists/netdev/msg182467.html
> http://www.spinics.net/lists/netdev/msg182858.html
> http://lists.openwall.net/netdev/2011/12/15/45

These patches will have to be redone to work with the revised include
files. The iproute2 changes are not acceptable as is because they do no=
t support
older kernels.

It is critical that the resulting code work on both old and new
kernels. In other words, when the new ss command is built (using your
patches and 3.3 headers), it:
 * SHOULD send new diag requests to kernel and be able to display
   the new UNIX domain info
 * MUST still work when run against old 3.2 kernel.

This means the code should send new request first, and if that generate=
s
an error fallback (silently) to the old message format.
