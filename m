From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c59x: fix build failure on !CONFIG_PCI
Date: Thu, 18 Nov 2010 10:48:00 -0800 (PST)
Message-ID: <20101118.104800.70193768.davem@davemloft.net>
References: <20101116091408.abd36ec8.randy.dunlap@oracle.com>
	<1289960532.1663.24.camel@leonhard>
	<4CE3FBAC.3030503@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: namhyung@gmail.com, klassert@mathematik.tu-chemnitz.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33091
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755887Ab0KRSrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 13:47:35 -0500
In-Reply-To: <4CE3FBAC.3030503@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Randy Dunlap <randy.dunlap@oracle.com>
Date: Wed, 17 Nov 2010 07:58:36 -0800

> On 11/16/10 18:22, Namhyung Kim wrote:
>> 2010-11-16 (=C8=AD), 09:14 -0800, Randy Dunlap:
>>> Hi,
>>>
>>=20
>> Hi, Randy
>>=20
>>=20
>>> Interesting patch.  I have reported this build error and looked
>>> into fixing it, but did not come up with this solution.
>>>
>>> Looking at it more:  if CONFIG_PCI is not enabled, DEVICE_PCI() is =
NULL.
>>> That makes VORTEX_PCI() (with or without your patch) have a value o=
f NULL.
>>>
>>> Is the line with the reported syntax error (3211) executed in
>>> function acpi_set_WOL() ?  If so, let's assume that vp->enable_wol =
is true.
>>> Then what happens on line 3211 (or 3213 after your patch)?
>>>
>>> 		if (VORTEX_PCI(vp)->current_state < PCI_D3hot)
>>> 			return;
>>>
>>> or if I am really confuzed this morning, please tell me how it work=
s.
>>>
>>=20
>> At first glance, I've noticed that the code above could make a NULL
>> dereference so I added NULL check prior to the line.
>>=20
>> But after reading more code I realized that other pci-functions call=
ed
>> in acpi_set_WOL() would not work with NULL pci_dev pointer also. And=
 I
>> found all callers of the acpi_set_WOL() already checked NULL pointer
>> before the call. Finally I could remove the NULL check and leave the
>> code as is. That's how it works. :)
>=20
> I see.  and concur.  Thanks for the explanation.

Looks good to me too, applied, thanks!
