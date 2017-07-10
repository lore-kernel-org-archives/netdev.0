From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next RFC 08/12] net: dsa: Remove support for bypass bridge port attributes/vlan set
Date: Mon, 10 Jul 2017 13:13:57 -0400
Message-ID: <87tw2kb4fe.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1499268990-19251-1-git-send-email-arkadis@mellanox.com> <1499268990-19251-9-git-send-email-arkadis@mellanox.com> <9b066beb-190f-ddc8-74bd-c59cee98d059@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        andrew@lunn.ch, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: Florian Fainelli <f.fainelli@gmail.com>,
        Arkadi Sharshevsky <arkadis@mellanox.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:39740 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932271AbdGJRQh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 13:16:37 -0400
In-Reply-To: <9b066beb-190f-ddc8-74bd-c59cee98d059@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian, Arkadi,

Florian Fainelli <f.fainelli@gmail.com> writes:

> I would be more comfortable if we still had a way to dump HW entries by
> calling into drivers, because it's useful for debugging, and doing that
> using standard tools plus an additional flag for instance:
>
> bridge fdb show
>
> would dump the SW-maintained VLANs, but:
>
> bridge fdb show hw

I don't think this makes much sense because the network hardware
architecture must be abstracted to the user, who only deals with user
network interfaces. This is also only needed for development and debug.

> would dump the HW-maintained VLANs, or any flag name really, but the
> point is that we can keep using a standard tool to expose debugging
> features. debugfs (or something else) could be used, but was rejected by
> David.

IIRC, what David is opposed to is having a *driver specific* debugfs
interface, i.e. debugfs for only mv88e6xxx. But he was opened to having
a *generic* debugfs interface in net/dsa/ from which any DSA chip
(e.g. lan9303, b53, qca8k, etc.) would benefit.

That makes even more sense for CPU and DSA ports which are not exposed
to userspace. Andrew played with dpipe but that wasn't quite satisfying
if I'm not mistaken. What we need for development and debug is a compile
time enableable interface to simply call into dsa_switch_ops directly.

So far here's what I have: port's VLAN, FDB, MDB, regs, stats, and
switch fabric topology (symlinks between interfaces): http://ix.io/yq0

I can split and submit this as RFC and see if I get slapped.


Thanks,

        Vivien
