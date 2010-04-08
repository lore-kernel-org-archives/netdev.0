From: Laurent Chavey <chavey@google.com>
Subject: Re: [PATCH 1/1] add ethtool loopback support
Date: Thu, 8 Apr 2010 15:43:34 -0700
Message-ID: <j2r97949e3e1004081543h6258125dm60083556ff28fa88@mail.gmail.com>
References: <pvmbpdtn8yh.fsf@chavey.mtv.corp.google.com> <1270751373.5055.22.camel@achroite.uk.solarflarecom.com>
	<w2i97949e3e1004081217jdeca953dz162c62b61c0e8f72@mail.gmail.com>
	<1270755356.5055.23.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, therbert@google.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:26353 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933331Ab0DHWn6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 18:43:58 -0400
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [10.3.21.13])
	by smtp-out.google.com with ESMTP id o38MhuQb006070
	for <netdev@vger.kernel.org>; Thu, 8 Apr 2010 15:43:56 -0700
Received: from gyd5 (gyd5.prod.google.com [10.243.49.197])
	by hpaq13.eem.corp.google.com with ESMTP id o38MhZcw017227
	for <netdev@vger.kernel.org>; Fri, 9 Apr 2010 00:43:55 +0200
Received: by gyd5 with SMTP id 5so1334066gyd.32
        for <netdev@vger.kernel.org>; Thu, 08 Apr 2010 15:43:54 -0700 (PDT)
In-Reply-To: <1270755356.5055.23.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 8, 2010 at 12:35 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Thu, 2010-04-08 at 12:17 -0700, Laurent Chavey wrote:
>> On Thu, Apr 8, 2010 at 11:29 AM, Ben Hutchings
>> <bhutchings@solarflare.com> wrote:
>> > On Thu, 2010-04-08 at 10:35 -0700, chavey@google.com wrote:
> [...]
>> >> +enum ethtool_loopback_type {
>> >> + =A0 =A0 ETH_MAC =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D 0x00000001,
>> >> + =A0 =A0 ETH_PHY_INT =A0 =A0 =A0 =A0 =A0 =A0 =3D 0x00000002,
>> >> + =A0 =A0 ETH_PHY_EXT =A0 =A0 =A0 =A0 =A0 =A0 =3D 0x00000004
>> >> +};
>> > [...]
>> >
>> > There are many different places you can loop back within a MAC or =
PHY,
>> > not to mention bypassing the MAC altogether. =A0See
>> > drivers/net/sfc/mcdi_pcol.h, starting from the line
>> > '#define MC_CMD_LOOPBACK_NONE 0'. =A0I believe we implement all of=
 those
>> > loopback modes on at least one board.
>> >
>> > Also are these supposed to be an enumeration or flags? =A0In theor=
y you
>> those are enums that can be or together.
>
> I.e. they are flags. =A0So how do you answer this:
>
>> > could use wire-side and host-side loopback at the same time if the=
y
>> > don't overlap, but it's probably too much trouble to bother with. =
=A0Any
>> > other combination is meaningless.
since the intent is to enable the sending and receiving of packets at
the hw/driver interfaces, a simple loopback mode on/off is sufficient
and the ethtool_loopback_type are not necessary. the implementor can ch=
oose
how to implement the loopback. From drivers/net/sfc/mcdi_pcol.h it is c=
lear
that unless ethtool_loopback_type as defined are meaningless.

> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>
