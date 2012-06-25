From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Mon, 25 Jun 2012 16:08:52 +0800
Message-ID: <CACVXFVOPjFSS6Sv6AUCSAs4nywR045QhjYAbN8g6U3adsUbujw@mail.gmail.com>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no>
	<201206232255.08319.oliver@neukum.org>
	<877guxhx44.fsf@nemi.mork.no>
	<201206241413.08339.oliver@neukum.org>
	<0e34226c-8fe7-4e2e-8fc2-2ed140f23e9b@email.android.com>
	<CACVXFVN3wJ3NWxSGj-yWCgtDE_sgJT5CZYHwYUWk1MxkphcsTg@mail.gmail.com>
	<87hatzhn0k.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org,
	=?ISO-8859-1?Q?Marius_Bj=F8rnstad_Kotsbak?=
	<marius.kotsbak@gmail.com>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:39636 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518Ab2FYIIw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 04:08:52 -0400
In-Reply-To: <87hatzhn0k.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 25, 2012 at 3:24 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:

>
> True, but irrelevant. =A0The pointer is either valid or NULL. =A0We d=
on't
> need to care about synchronizing the exact time it is set to NULL.
>
> The locking in cdc-wdm will ensure that the pointer is valid while it=
 is
> in use by .manage_power, because usbnet_disconnect is prevented from
> continuing with free_netdev() while any caller of .manage_power is
> running.

What I mean is that the situation is just what moving the set to NULL
is doing.

>> So it is only the sync mechanism that =A0works on the race even the =
check is
>> added in the patch. =A0Putting usb_set_intfdata(, NULL) after driver=
_info->unbind
>> should be OK, and it is a general solution for the problem.
>
> There is no problem wrt qmi_wwan and intfdata as long as the NULL tes=
t
> is added to .manage_power.

It depends on the ARCH or compiler.

Considered there is not any locking/memory barrier between the set to N=
ULL
and read the pointer, also no ACCESS_ONCE on read or store the pointer,
reading in .manage_power may see a invalid pointer if the CPU doesn't
support Store Atomicity or the compiler does a byte-at-a-time optimizat=
ion
on the store[1].

So why not take the correct way in theory? also it is a general solutio=
n,
and we can document its usage.


[1], Paul mentioned it in the previous discussion
http://lkml.org/lkml/2012/6/6/280

Thanks,
--=20
Ming Lei
