From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2] net: dsa: make "label" property optional for dsa2
Date: Mon, 09 Jan 2017 10:04:50 -0500
Message-ID: <877f6446lp.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170108231552.26995-1-vivien.didelot@savoirfairelinux.com> <20170109073236.GA1862@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Uwe =?utf-8?Q?Kleine-K=C3=B6nig?= <uwe@kleine-koenig.org>,
        Andrey Smirnov <andrew.smirnov@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:38642 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761689AbdAIPFM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 10:05:12 -0500
In-Reply-To: <20170109073236.GA1862@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

Jiri Pirko <jiri@resnulli.us> writes:

>>    # cat /etc/udev/rules.d/90-net-dsa.rules
>>    SUBSYSTEM=="net", ACTION=="add", ENV{DEVTYPE}=="dsa", PROGRAM="/lib/udev/dsanitizer $attr{phys_switch_id} $attr{phys_port_id}", NAME="$result"
>
> I know this is kind of confusing, but phys_port_id is to be used to
> indicate same physical port that is shared by multiple netdevices- for
> example sr-iov usecase. For switchdev usecase, you should use
> phys_port_name.
>
> I will add some documentation to kernel regarding this. But I see that
> net/dsa/slave.c already implements .ndo_get_phys_port_id :(
>
> I recently made changes in udev so it names the switch ports according
> to phys_port_name, out of the box, without need for any rules:
> https://github.com/systemd/systemd/pull/4506/commits/c960caa0c2a620fc506c6f0f7b6c40eeace48e4d

Thanks for the details. So if I understand correctly, what will be found
in phys_port_name will be used as is by udev to name the interface?

Extra question: shouldn't phys_port_{id,name} be switchdev attributes in
addition to SWITCHDEV_ATTR_ID_PORT_PARENT_ID?

> I guess that it should be enough for you to implement
> ndo_get_phys_port_name.

Well, if this name must be unique on a system, it's not likely to happen
until we agree that we use an ugly tXsYpZ template where X is a tree ID,
or we assign system-wide unique IDs to switches, which requires a bit of
changes.

I'm thinking, since DSA slaves are switchdev users, can't we all use a
switchdev helper to optionally get a system-wide unique name for a given
switch port? e.g. a template such as "swp%d"? I'd prefer that switchdev
and DSA do not diverge much when it comes to implement such attributes.

But again, this is not related to this patch ;-)

Thanks,

        Vivien
