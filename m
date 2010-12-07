From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH] atm: correct sysfs 'device' link creation and parent relationships
Date: Tue, 7 Dec 2010 08:35:53 +0100
Message-ID: <AANLkTikhkVPcibAH8cSRvZSLop=Ew19Tn=KtY7prkKUn@mail.gmail.com>
References: <1291587480.17538.12.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Duncan Sands <duncan.sands@free.fr>,
	linux-usb@vger.kernel.org, Chas Williams <chas@cmf.nrl.navy.mil>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f180.google.com ([209.85.161.180]:44785 "EHLO
	mail-gx0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752425Ab0LGHgJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 02:36:09 -0500
In-Reply-To: <1291587480.17538.12.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 5, 2010 at 23:17, Dan Williams <dcbw@redhat.com> wrote:
> The ATM subsystem was incorrectly creating the 'device' link for ATM
> nodes in sysfs. =C2=A0This led to incorrect device/parent relationshi=
ps
> exposed by sysfs and udev. =C2=A0Instead of rolling the 'device' link=
 by hand
> in the generic ATM code, pass each ATM driver's bus device down to th=
e
> sysfs code and let sysfs do this stuff correctly.

Looks good to me.

It's wrong for any subsystem to ever create a file or link named
"device". It's a built-in driver-core managed property which appears
automatically as soon as the parent-device relations are correctly
established.

Udev/libudev intentionally refuses to follow any devices pointed to by
"broken" device links. So this patch is needed to make ATM devices
working properly with usual userspace tools.

Thanks,
Kay
