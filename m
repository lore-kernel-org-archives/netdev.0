From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [RFC PATCH] platform: Faciliatate the creation of pseduo-platform
	busses
Date: Thu, 5 Aug 2010 17:00:59 -0600
Message-ID: <AANLkTi=Mk_0en5ojVZaKrjw14DbY57agF4nztQfQrx1M@mail.gmail.com>
References: <4C58A7AA.8020007@codeaurora.org> <20100803235631.GA17759@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick Pannuto <ppannuto@codeaurora.org>,
	linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	linux-omap@vger.kernel.org, damm@opensource.se,
	lethal@linux-sh.org, rjw@sisk.pl, dtor@mail.ru,
	eric.y.miao@gmail.com, netdev@vger.kernel.org
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:51356 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934870Ab0HEXBU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 19:01:20 -0400
In-Reply-To: <20100803235631.GA17759@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 3, 2010 at 5:56 PM, Greg KH <gregkh@suse.de> wrote:
> On Tue, Aug 03, 2010 at 04:35:06PM -0700, Patrick Pannuto wrote:
>> @@ -539,12 +541,12 @@ int __init_or_module platform_driver_probe(str=
uct platform_driver *drv,
>> =A0 =A0 =A0 =A0* if the probe was successful, and make sure any forc=
ed probes of
>> =A0 =A0 =A0 =A0* new devices fail.
>> =A0 =A0 =A0 =A0*/
>> - =A0 =A0 spin_lock(&platform_bus_type.p->klist_drivers.k_lock);
>> + =A0 =A0 spin_lock(&drv->driver.bus->p->klist_drivers.k_lock);
>> =A0 =A0 =A0 drv->probe =3D NULL;
>> =A0 =A0 =A0 if (code =3D=3D 0 && list_empty(&drv->driver.p->klist_de=
vices.k_list))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D -ENODEV;
>> =A0 =A0 =A0 drv->driver.probe =3D platform_drv_probe_fail;
>> - =A0 =A0 spin_unlock(&platform_bus_type.p->klist_drivers.k_lock);
>> + =A0 =A0 spin_unlock(&drv->driver.bus->p->klist_drivers.k_lock);
>>
>> =A0 =A0 =A0 if (code !=3D retval)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 platform_driver_unregister(drv);
>
> I'm guessing that this chunk can be applied now, right?

Yes, I agree.  This chunk makes sense independently of the rest of the =
patch.

g.
