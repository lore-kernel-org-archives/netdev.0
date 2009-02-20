From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: NAPI of many interfaces with just an interruption source
Date: Fri, 20 Feb 2009 10:54:13 -0800
Message-ID: <20090220105413.55e4f5f6@extreme>
References: <b0438a630902201033l395edc7ck4a2749e239797445@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Miguel =?UTF-8?B?w4FuZ2VsIMOBbHZhcmV6?= <gotzoncabanes@gmail.com>
To: Miguel =?UTF-8?B?w4FuZ2VsIMOBbHZhcmV6?= <gotzoncabanes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48042 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752957AbZBTSyP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 13:54:15 -0500
In-Reply-To: <b0438a630902201033l395edc7ck4a2749e239797445@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Feb 2009 19:33:23 +0100
Miguel =C3=81ngel =C3=81lvarez <gotzoncabanes@gmail.com> wrote:

> Hi
>=20
> I have four interfaces that share the same interruption source (four
> hdlc channels in ixp4xx that share the same rx queue... but I am
> trying to do the question generic).
>=20
> My first approach was to declare a napi interface for each device.
> When I detected the first interrupt, I determine the correct net
> interface, and schedule a poll for it.
>=20
> The question is that there is no warranty that the data received in
> the polling belongs to the same interface, so...
>=20
> - It is correct to do like this, and just analyse the data to check t=
o
> which net interface should the data be sent.
> - Or NAPI is not correct for this case and we should just use the
> simple interruption mechanism?
>=20
> Thanks
>=20
> Miguel =C3=81ngel =C3=81lvarez

Several other devices have this (like sky2).  Since NAPI needs
to control irq, you need to have 1 NAPI instance per IRQ, so for
these type of drivers there is 1 NAPI in hardware structure
and multiple network devices.

Note: netconsole/netpoll will only work on a single channel,
but usually a big issue.
