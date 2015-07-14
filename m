From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH/RFC net-next] rocker: forward packets to CPU when a port
 in promiscuous mode
Date: Mon, 13 Jul 2015 23:37:59 -0700
Message-ID: <CAE4R7bChu5sAKpU5tUkENfWZMhaWSs3EQZeggUxR=BjKSOqOeg@mail.gmail.com>
References: <1436415931-16469-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	john fastabend <john.fastabend@gmail.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:32796 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503AbbGNGiT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 02:38:19 -0400
Received: by oige126 with SMTP id e126so375432oig.0
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 23:38:19 -0700 (PDT)
In-Reply-To: <1436415931-16469-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 8, 2015 at 9:25 PM, Simon Horman <simon.horman@netronome.co=
m> wrote:
> This change allows the CPU to see all packets seen by a port when the
> netdev associated with the port is in promiscuous mode.
>
> This change was previously posted as part of a larger patch and in tu=
rn
> patchset which also aimed to allow rocker interfaces to receive packe=
ts
> when not bridged. That problem has subsequently been addressed in a
> different way by Scott Feldman.
>
> When this change was previously posted Scott indicated that he had so=
me
> reservations about sending all packets from a switch to the CPU. The
> purpose of posting this patch is to start discussion of weather this
> approach is appropriate and if not how else we might move forwards.
>
> In my opinion if host doesn't want all packets its shouldn't put a po=
rt
> in promiscuous mode. But perhaps that is an overly na=C3=AFve view to=
 take.
>
> My main motivation for this change at this time is to allow rocker to
> work with Open vSwitch and it appears that this change is sufficient =
to
> reach that goal. Another approach might be to teach
> rocker_port_master_changed() about Open vSwitch.
>
> In the longer term I believe Open vSwitch should be able to program
> flows into rocker 'hardware' and thus not all packets would reach the=
 CPU.

Hi Simon,

I like your alternate approach to teach rocker about Open vSwitch
using rocker_port_master_change() and only when port is captured by
OVS would we install the "promisc" filter to pass all traffic up.
(Maybe call it ROCKER_CTRL_DFLT_OVS rule?).

Putting a non-bridged, non-ovs port into promisc is kind of weird for
a switch port.  I think of the port in L3 mode by default, where the
port is locked down for all but some selective mcasts, and only opened
up by installing explicit routes.  (Unlike a bridged port where we
flood everything L2 we don't understand).

So maybe first pass is to pass up everything when port is captured by
OVS, and then later refine what's passed up per ovs flows on that
port.

-scott
