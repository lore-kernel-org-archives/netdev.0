From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 00/27] Remove VLAN CFI bit abuse
Date: Tue, 13 Dec 2016 17:16:26 -0800
Message-ID: <20161213171626.76e7dced@xeon-e3>
References: <cfa1f2efae2217b50cbefccbf9ba7f0d24a23c63.1480755768.git.mirq-linux@rere.qmqm.pl>
        <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:34297 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752359AbcLNBQ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 20:16:57 -0500
Received: by mail-pg0-f49.google.com with SMTP id x23so1792314pgx.1
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2016 17:16:35 -0800 (PST)
In-Reply-To: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Dec 2016 01:12:32 +0100 (CET)
Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> wrote:

> Dear NetDevs
>=20
> This series removes an abuse of VLAN CFI bit in Linux networking stack.
> Currently Linux always clears the bit on outgoing traffic and presents
> it cleared to userspace (even via AF_PACKET/tcpdump when hw-accelerated).
>=20
> This uses a new vlan_present bit in struct skbuff, and removes an assumpt=
ion
> that vlan_proto !=3D 0 when VLAN tag is present.
>=20
> As I can't test most of the driver changes, please look at them carefully.
>=20
> The series is supposed to be bisect-friendly and that requires temporary
> insertion of #define VLAN_TAG_PRESENT in BPF code to be able to split
> JIT changes per architecture.
>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw

I wonder if CFI can every validly be non-zero in the modern world, on Hyper=
-V.
There are no token ring devices and that seems to be the only use case wher=
e CFI would
be non-zero. Unless someone is planning to reuse it a a protocol bit which =
seems
like a really bad idea.

Maybe the right thing is to keep hard coded as zero and not start adding
more untestable code conditions.

My recommendation would be get rid of VLAN_TAG_PRESENT, but don't preserve
CFI bit.
