From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: Iproute2 build broken by current kernel headers
Date: Wed, 11 Jan 2012 10:34:48 +0400
Message-ID: <4F0D2D88.8010705@parallels.com>
References: <20120110105409.3567bb1b@nehalam.linuxnetplumber.net> <20120110110749.42c1252a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:27921 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753321Ab2AKGe4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jan 2012 01:34:56 -0500
In-Reply-To: <20120110110749.42c1252a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2012 11:07 PM, Stephen Hemminger wrote:
> On Tue, 10 Jan 2012 10:54:09 -0800
> Stephen Hemminger <shemminger@vyatta.com> wrote:
>=20
>> The update to inet diag broke compatibility with exported headers.
>> Iproute2 uses sanitized kernel headers.
>>
>> gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -I../include -DRESOL=
VE_HOSTNAMES -DLIBDIR=3D\"/usr/lib/\"   -c -o ss.o ss.c
>> ss.c: In function =E2=80=98tcp_show_netlink=E2=80=99:
>> ss.c:1504:7: error: =E2=80=98struct inet_diag_req=E2=80=99 has no me=
mber named =E2=80=98idiag_family=E2=80=99
>> make[1]: *** [ss.o] Error 1
>=20
> The structures need to be swapped to maintain source compatibility.
> inet_diag_req_compat needs to be renamed back to inet_diag_req
> inet_diag_req should be named something like inet_diag_req_generic

Stephen, actually the diag modules were patched to be only binary compa=
tible with the ss.
In order to make it compile with new headers I've sent the patches fixi=
ng ss, here they are:

http://www.spinics.net/lists/netdev/msg182467.html
http://www.spinics.net/lists/netdev/msg182858.html
http://lists.openwall.net/netdev/2011/12/15/45
