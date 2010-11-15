From: Eliad Peller <eliad@wizery.com>
Subject: Re: netlink_carrier_on() race condition?
Date: Mon, 15 Nov 2010 02:15:12 +0200
Message-ID: <AANLkTi=cxAYXPKDMfURNX_=xU4Leqp6s6Dmbzam3q56_@mail.gmail.com>
References: <AANLkTin4VvU9vXKT=5mmJFYN==YB5QfjOMo2cHQ0b5bJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:38875 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753587Ab0KOAPO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Nov 2010 19:15:14 -0500
Received: by gyh4 with SMTP id 4so2714794gyh.19
        for <netdev@vger.kernel.org>; Sun, 14 Nov 2010 16:15:13 -0800 (PST)
In-Reply-To: <AANLkTin4VvU9vXKT=5mmJFYN==YB5QfjOMo2cHQ0b5bJ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

i'm still waiting for some response regarding this issue.
i've encountered this concrete issue, and i want to make sure i fully
understand the situation before submitting some redundant patch.

thanks,
Eliad.

On Thu, Nov 4, 2010 at 9:43 PM, Eliad Peller <eliad@wizery.com> wrote:
> hi,
>
> i might be missing something, but i think there is some race conditio=
n
> in netlink_carrier_on():
> when calling it, it clears the __LINK_STATE_NOCARRIER flag and
> enqueues a work to do everything needed.
> this cause a period, in which =A0__LINK_STATE_NOCARRIER is unset (whi=
ch
> implies IFF_LOWER_UP), but the default qdiscs are not attached yet
> (since the work hasn't been executed yet).
> userspace might get some netlink events (e.g. wireless wext) in which
> the IFF_LOWER_UP flag is set, but the queues are not ready.
>
> shouldn't we clear the flag only after all the work is done?
>
> thanks,
> Eliad.
>
