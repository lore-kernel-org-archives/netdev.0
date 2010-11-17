From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] 3c59x: fix build failure on !CONFIG_PCI
Date: Wed, 17 Nov 2010 07:58:36 -0800
Message-ID: <4CE3FBAC.3030503@oracle.com>
References: <1289921271-15295-1-git-send-email-namhyung@gmail.com>	 <20101116091408.abd36ec8.randy.dunlap@oracle.com> <1289960532.1663.24.camel@leonhard>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Namhyung Kim <namhyung@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:59593 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934749Ab0KQP7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 10:59:48 -0500
In-Reply-To: <1289960532.1663.24.camel@leonhard>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/10 18:22, Namhyung Kim wrote:
> 2010-11-16 (=ED=99=94), 09:14 -0800, Randy Dunlap:
>> Hi,
>>
>=20
> Hi, Randy
>=20
>=20
>> Interesting patch.  I have reported this build error and looked
>> into fixing it, but did not come up with this solution.
>>
>> Looking at it more:  if CONFIG_PCI is not enabled, DEVICE_PCI() is N=
ULL.
>> That makes VORTEX_PCI() (with or without your patch) have a value of=
 NULL.
>>
>> Is the line with the reported syntax error (3211) executed in
>> function acpi_set_WOL() ?  If so, let's assume that vp->enable_wol i=
s true.
>> Then what happens on line 3211 (or 3213 after your patch)?
>>
>> 		if (VORTEX_PCI(vp)->current_state < PCI_D3hot)
>> 			return;
>>
>> or if I am really confuzed this morning, please tell me how it works=
=2E
>>
>=20
> At first glance, I've noticed that the code above could make a NULL
> dereference so I added NULL check prior to the line.
>=20
> But after reading more code I realized that other pci-functions calle=
d
> in acpi_set_WOL() would not work with NULL pci_dev pointer also. And =
I
> found all callers of the acpi_set_WOL() already checked NULL pointer
> before the call. Finally I could remove the NULL check and leave the
> code as is. That's how it works. :)

I see.  and concur.  Thanks for the explanation.

--=20
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your cod=
e ***
