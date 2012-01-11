From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: Iproute2 build broken by current kernel headers
Date: Wed, 11 Jan 2012 10:58:51 +0400
Message-ID: <4F0D332B.3090105@parallels.com>
References: <20120110105409.3567bb1b@nehalam.linuxnetplumber.net>	<20120110110749.42c1252a@nehalam.linuxnetplumber.net>	<4F0D2D88.8010705@parallels.com> <20120110.223907.553192715910149190.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:42789 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750828Ab2AKG65 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jan 2012 01:58:57 -0500
In-Reply-To: <20120110.223907.553192715910149190.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/11/2012 10:39 AM, David Miller wrote:
> From: Pavel Emelyanov <xemul@parallels.com>
> Date: Wed, 11 Jan 2012 10:34:48 +0400
>=20
>> On 01/10/2012 11:07 PM, Stephen Hemminger wrote:
>>> On Tue, 10 Jan 2012 10:54:09 -0800
>>> Stephen Hemminger <shemminger@vyatta.com> wrote:
>>>
>>>> The update to inet diag broke compatibility with exported headers.
>>>> Iproute2 uses sanitized kernel headers.
>>>>
>>>> gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -I../include -DRES=
OLVE_HOSTNAMES -DLIBDIR=3D\"/usr/lib/\"   -c -o ss.o ss.c
>>>> ss.c: In function =A1tcp_show_netlink=A2:
>>>> ss.c:1504:7: error: =A1struct inet_diag_req=A2 has no member named=
 =A1idiag_family=A2
>>>> make[1]: *** [ss.o] Error 1
>>>
>>> The structures need to be swapped to maintain source compatibility.
>>> inet_diag_req_compat needs to be renamed back to inet_diag_req
>>> inet_diag_req should be named something like inet_diag_req_generic
>>
>> Stephen, actually the diag modules were patched to be only binary co=
mpatible with the ss.
>> In order to make it compile with new headers I've sent the patches f=
ixing ss, here they are:
>>
>> http://www.spinics.net/lists/netdev/msg182467.html
>> http://www.spinics.net/lists/netdev/msg182858.html
>> http://lists.openwall.net/netdev/2011/12/15/45
>=20
> You can't do this Pavel, what about other userspace programs which
> might have been compiled against these headers? Any data structure
> exported to userspace is FIXED, can't you understand this?

I do understand :( But the same was done by acme@ when he generalized t=
cp_diag
to support dccp sockets -- he just renamed the tcp_diag_* into the inet=
_diag_*=20
thus preserving only the binary compatibility.

> You've very much handled backwards compatability terribly in these pa=
thces,
> I should have forced you let them cook for another full release cycle=
=2E
> :-/

Do I have 24 hours for fixing this? If I don't then just revert the who=
le
set, I will start this again after the current merge window closes.

Thanks,
Pavel
