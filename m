From: Daniel Lezcano <daniel.lezcano@linaro.org>
Subject: Re: [PATCH v1] net/core: support runtime PM on net_device
Date: Thu, 18 Oct 2012 18:34:18 +0200
Message-ID: <50802F8A.6090205@linaro.org>
References: <1350548469-1267-1-git-send-email-ming.lei@canonical.com> <8762689o9u.fsf@nemi.mork.no> <CACVXFVPu1m3CJaFavW9eaU3Z850q+x1N_Yo7tri1UTFpgfYVXQ@mail.gmail.com> <87obk080us.fsf@nemi.mork.no> <CACVXFVMmSFHYU-sNHRM7g_8U6mjbdbE+bNPxM-F8iAB=4WudRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Oliver Neukum <oneukum@suse.de>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-pm@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:52138 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932125Ab2JRQeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 12:34:22 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so4276230bkc.19
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2012 09:34:21 -0700 (PDT)
In-Reply-To: <CACVXFVMmSFHYU-sNHRM7g_8U6mjbdbE+bNPxM-F8iAB=4WudRA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/2012 02:55 PM, Ming Lei wrote:
> On Thu, Oct 18, 2012 at 7:40 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrot=
e:
>>
>> Because bugs are supposed to be fixed and not hidden?
>=20
> OK, now let's discuss solution for the problem which should be
> clear and be solved.
>=20
> The 1st one is to do it by this patch, or rule out some ioctl cmd
> which needn't wakeup device.
>=20
> The second one is to fix ioctl one by one in each driver.
>=20
> Any other solution?
>=20
>>
>> Note that I am not claiming this is a bug.  That is still an open
>> question as far as I can see.

Hi Ming,

IIUC, the pm_runtime is related to the device drivers, so at the first
glance, we should see invocation of the runtime's functions in drivers/=
*
and arch/*. Adding these calls in the net core, which makes sense at a
certain point, is a bit weird for me.

=46rom my POV, if the drivers have been modified to support the pm_runt=
ime
and this new functionality brought a regression with the ioctl, that
should be fixed in the drivers and not in the core code.

What happens with your patch if we use ethtool on a virtual device like
veth, macvlan, bridge, ... ?

Shouldn't handle the mac address, mtu, ... changes with the rtnetlink a=
lso ?

Thanks
  -- Daniel

--=20
 <http://www.linaro.org/> Linaro.org =E2=94=82 Open source software for=
 ARM SoCs

=46ollow Linaro:  <http://www.facebook.com/pages/Linaro> Facebook |
<http://twitter.com/#!/linaroorg> Twitter |
<http://www.linaro.org/linaro-blog/> Blog
