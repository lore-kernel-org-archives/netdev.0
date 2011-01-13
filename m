From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: Re: [PATCH] ipv4: devconf: start IPV4_DEVCONF_* from 0
Date: Thu, 13 Jan 2011 09:50:14 +0200
Message-ID: <AANLkTimLyNf-sgLtzf0i3k7om9MEQ2t8tSOwDcpS66dv@mail.gmail.com>
References: <AANLkTin1LCgEpBNay_o4dzF1ONKanR1HRqcOu3AqqyHu@mail.gmail.com> <20110112.184734.38051229.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, tgraf@infradead.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, opurdila@ixiacom.com, ddvlad@rosedu.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:46542 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447Ab1AMHuf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 02:50:35 -0500
Received: by iyj18 with SMTP id 18so1278743iyj.19
        for <netdev@vger.kernel.org>; Wed, 12 Jan 2011 23:50:34 -0800 (PST)
In-Reply-To: <20110112.184734.38051229.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 13, 2011 at 4:47 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
> Date: Wed, 12 Jan 2011 12:19:10 +0200
>
>> The IPV4_DEVCONF_* enums are never exposed to the userspace and it
>> would make code simpler to remove all the useless (-1) adjustments.
>
> Starting values like this at "1" is usually done on purpose.
>
> It allows "0" to be illegal or mean "none", and thus easily trapping
> cases where the value fails to be initialized properly. =C2=A0In this=
 way
> the illegal sentinel "0" doesn't take up any space either.


Just that no one checks for zero as invalid anywhere.

We pass the enum names everywhere as parameters. And wherever we need
to use those values we must make sure to subtract 1 every time.

And some things work ok, but it's not entirely obvious why.

=46or example:
	struct ctl_table devinet_vars[__IPV4_DEVCONF_MAX] (...) =3D {
                DEVINET_SYSCTL_COMPLEX_ENTRY(FORWARDING, "forwarding",
                                             devinet_sysctl_forward),

This works ok because the DEVINET_SYSCTL_* macros subtract 1 from each
array index.

Because the size of the array is __IPV4_DEVCONF_MAX (without
subtracting 1), there's an extra element at the end and because this
is a global definition it gets initialized with zeros just as required
by register_net_sysctl_table: the last element's procname must be zero
to indicate end-of-array.

Yes it works, but there does not seem to be a good reason why to
complicate things like this (again the sentinel nature of zero is not
used in any place here).


--=20
=C2=A0.
=2E.: Lucian
