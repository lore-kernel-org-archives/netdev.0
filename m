From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: data vs overhead bytes, netperf aggregate RR and retransmissions
Date: Wed, 3 Aug 2011 23:37:32 -0700
Message-ID: <CAEuXFEzemZxw5PVTzJeEZD=csyrB6uTWO6m-hZTdKqUvhBAhxQ@mail.gmail.com>
References: <4E386E98.1090606@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:59086 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806Ab1HDGhd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2011 02:37:33 -0400
Received: by fxh19 with SMTP id 19so1417075fxh.19
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2011 23:37:32 -0700 (PDT)
In-Reply-To: <4E386E98.1090606@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 2, 2011 at 2:39 PM, Rick Jones <rick.jones2@hp.com> wrote:
> driver: igb
> version: 2.1.0-k2
> firmware-version: 1.8-2
> bus-info: 0000:05:00.0
>
> One of the things fixed recently in netperf (top-of-trunk, beyond 2.5=
=2E0) is
> I actually have reporting of per-connection TCP retransmissions worki=
ng. =A0I
> was looking at that, and noticed a bunch of retransmissions at the 25=
6 burst
> level with 24 concurrent netperfs. =A0I figured it was simple overloa=
d of say
> the switch or the one port active on the SUT (I do have one system ta=
lking
> to two, so perhaps some incast). =A0Burst 64 had retrans as well. =A0=
Burst 16
> and below did not. =A0That pattern repeated at 12 concurrent netperfs=
, and 8,
> and 4 and 2 and even 1 - yes, a single netperf aggregate TCP_RR test =
with a
> burst of 64 was reporting TCP retransmissions. =A0No incasting issues=
 there.
> =A0The network was otherwise clean.

Rick, can you reboot and try with idle=3Dpoll OR set ethtool -C ethX rx=
-usecs 0
both tests would be interesting, possibly relating your issue to cpu
power management and/or interrupt throttling, or some combo of both.

Also please check the ethtool -S ethX stats from the hardware, and
include them in your reply.
