From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Tue, 29 Nov 2011 15:57:47 +0100
Message-ID: <1322578667.2465.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <alpine.DEB.2.00.1111281825200.25622@pokey.mtv.corp.google.com>
	 <CAA93jw7P=7YMOS_sMQWBJx0UJ6e+xw4e_hw8szNiVTOjGNwukw@mail.gmail.com>
	 <1322550138.2970.70.camel@edumazet-laptop> <4ED4885F.8060309@intel.com>
	 <CAA93jw7prPymGuWdn0pgHXL81g19opm2=-T4msy-b_s2MJ9=Jw@mail.gmail.com>
	 <1322556234.2970.84.camel@edumazet-laptop>
	 <CAA93jw6bvzASrtvjhKL+haZb0VEPvQQD0guf7aBTPxJbxydEAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Tom Herbert <therbert@google.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:45476 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754396Ab1K2O5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 09:57:52 -0500
Received: by qyk4 with SMTP id 4so1635898qyk.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 06:57:52 -0800 (PST)
In-Reply-To: <CAA93jw6bvzASrtvjhKL+haZb0VEPvQQD0guf7aBTPxJbxydEAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 29 novembre 2011 =C3=A0 09:51 +0100, Dave Taht a =C3=A9crit :

> Perhaps I don't understand the gross effects of TSO very well, but if=
 you have
> 100 streams coming from a server, destined to X different destination=
s,
> and you FQ to each on a per packet basis, you end up impacting the do=
wnstream
> receive buffers throughout much less than if you send each stream as =
a burst.

TSO makes packets larger, to lower cpu use in different layers (netfilt=
er, qdisc, ...).

Imagine you could have MSS=3D65000 on your ethernet wire.

If you need to send a high prio packet while a prior big one is
in-flight on a dumb device (a single TX FIFO), there is nothing you
can do but wait last bit of big packet hit the wire.

Even with one flow you lose. Hundred flows dont matter
(as long as you have proper classification in Qdisc layer, of course)

Most setups dont care.

The ones caring dedicate a link for exclusive use, making sure it wont
cross loaded trunks. (Heartbeats in clusters)

Even disabling TSO wont be enough for them, if a single tcp flow can co=
mpete with them.
