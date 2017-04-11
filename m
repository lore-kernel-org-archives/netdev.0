From: Dmitry Krivenok <krivenok.dmitry@gmail.com>
Subject: Re: macvlan on top of balance-alb bond
Date: Tue, 11 Apr 2017 18:29:29 +0300
Message-ID: <CAJN_NGZsxsqES0mS6BgL1tBsuia0TsVoTq=CZ4nNrhmubCovqA@mail.gmail.com>
References: <CAJN_NGada81u96VSRz=puy3DOXjqJ6H9vNkMjgGFBea3vgrPPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:36759 "EHLO
        mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753078AbdDKP3l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 11:29:41 -0400
Received: by mail-yw0-f193.google.com with SMTP id 203so36463ywk.3
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 08:29:35 -0700 (PDT)
In-Reply-To: <CAJN_NGada81u96VSRz=puy3DOXjqJ6H9vNkMjgGFBea3vgrPPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[FIXED FORMATTING]

Hello,
I have a question concerning the setup where I have macvlan interface on to=
p of
bond device configured in balance-alb mode with 2 slave ports.

The problem is that I cannot ping an IP of macvlan device on the server fro=
m the
client machine. I do see that (as expected) the client never sees MAC addre=
ss of
macvlan device, but instead sees MAC address of one of the slave ports beca=
use
ARP replies are intercepted by bonding driver and MACs are replaced.
However, I don=E2=80=99t see ICMP requests from the client on macvlan devic=
e when I
run tcpdump. I do see them on bond device and the slave assigned to the cli=
ent
though.

I also tried active/passive, LACP and TLB bonding modes and they all work f=
ine
with my configuration. I only have a problem with ALB mode and macvlan.
When I moved IP from macvlan device to the bond device, everything started
working, so I guess it has something to do with virtual interfaces on top o=
f the
bond.

I=E2=80=99d think that such configuration is not supported, but I found the=
 following
patch that was merged few years ago:
https://www.spinics.net/lists/netdev/msg285148.html
>From the description, the patch was intended to add support of exactly my
configuration. I confirmed that my 4.8.6 kernel does have those changes.

I=E2=80=99m not familiar with the code of bonding driver and didn=E2=80=99t=
 dig into the source
code to see why packets get dropped. I see that they are dropped (via
dropwatch).
I tried to get more details via enabling dyndebug and playing with ftrace, =
but
with no luck yet.

Before I dig into that, I wanted check with experts to know if that
configuration
is supported at all with the latest Linux kernel? Any help is very apprecia=
ted!

Thanks,
Dmitry

On Tue, Apr 11, 2017 at 6:25 PM, Dmitry Krivenok
<krivenok.dmitry@gmail.com> wrote:
> Hello,
>
> I have a question concerning the setup where I have macvlan interface on =
top of
>
> bond device configured in balance-alb mode with 2 slave ports.
>
>
>
> The problem is that I cannot ping an IP of macvlan device on the server f=
rom the
>
> client machine. I do see that (as expected) the client never sees MAC add=
ress of
>
> macvlan device, but instead sees MAC address of one of the slave ports be=
cause
>
> ARP replies are intercepted by bonding driver and MACs are replaced.
>
> However, I don=E2=80=99t see ICMP requests from the client on macvlan dev=
ice when I
>
> run tcpdump. I do see them on bond device and the slave assigned to the c=
lient
>
> though.
>
>
>
> I also tried active/passive, LACP and TLB bonding modes and they all work=
 fine
>
> with my configuration. I only have a problem with ALB mode and macvlan.
>
> When I moved IP from macvlan device to the bond device, everything starte=
d
>
> working, so I guess it has something to do with virtual interfaces on top=
 of the
>
> bond.
>
>
>
> I=E2=80=99d think that such configuration is not supported, but I found t=
he following
>
> patch that was merged few years ago:
>
> https://www.spinics.net/lists/netdev/msg285148.html
>
> From the description, the patch was intended to add support of exactly my
>
> configuration. I confirmed that my 4.8.6 kernel does have those changes.
>
>
>
> I=E2=80=99m not familiar with the code of bonding driver and didn=E2=80=
=99t dig into the source
>
> code to see why packets get dropped. I see that they are dropped (via
> dropwatch).
>
> I tried to get more details via enabling dyndebug and playing with ftrace=
, but
>
> with no luck yet.
>
>
>
> Before I dig into that, I wanted check with experts to know if that
> configuration
>
> is supported at all with the latest Linux kernel? Any help is very apprec=
iated!
>
>
>
> Thanks,
>
> Dmitry



--=20
Sincerely yours, Dmitry V. Krivenok
e-mail: krivenok.dmitry@gmail.com
skype: krivenok_dmitry
jabber: krivenok_dmitry@jabber.ru
icq: 242-526-443
