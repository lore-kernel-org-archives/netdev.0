From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2] net: dsa: make "label" property optional for
 dsa2
Date: Mon, 9 Jan 2017 16:11:32 +0100
Message-ID: <20170109151131.GC1862@nanopsycho>
References: <20170108231552.26995-1-vivien.didelot@savoirfairelinux.com>
 <20170109073236.GA1862@nanopsycho>
 <877f6446lp.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <uwe@kleine-koenig.org>,
        Andrey Smirnov <andrew.smirnov@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <877f6446lp.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mon, Jan 09, 2017 at 04:04:50PM CET, vivien.didelot@savoirfairelinux.com wrote:
>Hi Jiri,
>
>Jiri Pirko <jiri@resnulli.us> writes:
>
>>>    # cat /etc/udev/rules.d/90-net-dsa.rules
>>>    SUBSYSTEM=="net", ACTION=="add", ENV{DEVTYPE}=="dsa", PROGRAM="/lib/udev/dsanitizer $attr{phys_switch_id} $attr{phys_port_id}", NAME="$result"
>>
>> I know this is kind of confusing, but phys_port_id is to be used to
>> indicate same physical port that is shared by multiple netdevices- for
>> example sr-iov usecase. For switchdev usecase, you should use
>> phys_port_name.
>>
>> I will add some documentation to kernel regarding this. But I see that
>> net/dsa/slave.c already implements .ndo_get_phys_port_id :(
>>
>> I recently made changes in udev so it names the switch ports according
>> to phys_port_name, out of the box, without need for any rules:
>> https://github.com/systemd/systemd/pull/4506/commits/c960caa0c2a620fc506c6f0f7b6c40eeace48e4d
>
>Thanks for the details. So if I understand correctly, what will be found
>in phys_port_name will be used as is by udev to name the interface?

Yes.


>
>Extra question: shouldn't phys_port_{id,name} be switchdev attributes in

Again, phys_port_id has nothing to do with switches. Should be removed
from dsa because its use there is incorrect.


>addition to SWITCHDEV_ATTR_ID_PORT_PARENT_ID?

Perhaps it could. Now it is a netdev op. I thinks it works nicely.


>
>> I guess that it should be enough for you to implement
>> ndo_get_phys_port_name.
>
>Well, if this name must be unique on a system, it's not likely to happen
>until we agree that we use an ugly tXsYpZ template where X is a tree ID,
>or we assign system-wide unique IDs to switches, which requires a bit of
>changes.

No. That should be unique within one switch. In mlxsw we name it "p1",
"p2", ...

The final netdev names are:
enp3s0np1, enp3s0np2, ...


>
>I'm thinking, since DSA slaves are switchdev users, can't we all use a
>switchdev helper to optionally get a system-wide unique name for a given
>switch port? e.g. a template such as "swp%d"? I'd prefer that switchdev
>and DSA do not diverge much when it comes to implement such attributes.

Again, not system-wide, just switch-wide.


>
>But again, this is not related to this patch ;-)

It is! You are using phys_port_id, which is completely wrong. You should
not use it.
