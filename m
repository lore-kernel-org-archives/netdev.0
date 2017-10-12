From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [RFC 0/3] Adding config get/set to devlink
Date: Thu, 12 Oct 2017 09:05:22 -0700
Message-ID: <CAJieiUhQsL14W5DTst=BRDcjMCavZPNRJf=9i2yOAfB6cLUeyg@mail.gmail.com>
References: <1507815262-33294-1-git-send-email-steven.lin1@broadcom.com>
 <CAJieiUjuKtmYDZ5-7UjYkWFJuMGu2gajhziLQKAZLTz6g63f2A@mail.gmail.com>
 <20171012144032.GG14672@nanopsycho> <CAJieiUiFmBr72yYP9VNtm0VBTNjJcA6Lj5nHJNBjDBC4moxE2A@mail.gmail.com>
 <20171012150419.GI14672@nanopsycho> <24E5DE7C-A401-48BF-BF80-673ACC38FBBE@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Jiri Pirko <jiri@resnulli.us>,
        Steve Lin <steven.lin1@broadcom.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        linux-pci@vger.kernel.org,
        "John W. Linville" <linville@tuxdriver.com>,
        Andy Gospodarek <gospo@broadcom.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <24E5DE7C-A401-48BF-BF80-673ACC38FBBE@gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 12, 2017 at 8:43 AM, Florian Fainelli <f.fainelli@gmail.com> wr=
ote:
> On October 12, 2017 8:04:19 AM PDT, Jiri Pirko <jiri@resnulli.us> wrote:
>>Thu, Oct 12, 2017 at 04:46:24PM CEST, roopa@cumulusnetworks.com wrote:
>>>On Thu, Oct 12, 2017 at 7:40 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> Thu, Oct 12, 2017 at 04:35:10PM CEST, roopa@cumulusnetworks.com
>>wrote:
>>>>>On Thu, Oct 12, 2017 at 6:34 AM, Steve Lin
>><steven.lin1@broadcom.com> wrote:
>>>>>> Adds a devlink command for getting & setting device configuration
>>>>>> parameters, and enumerates a bunch of those parameters as devlink
>>>>>> attributes.  Also introduces an attribute that can be set by a
>>>>>> driver to indicate that the config change doesn't take effect
>>>>>> until the next restart (as in the case of the bnxt driver changes
>>>>>> in this patchset, for which all the configuration changes affect
>>NVM
>>>>>> only, and aren't loaded until the next restart.)
>>>>>>
>>>>>> bnxt driver patches make use of these new devlink cmds/attributes.
>>>>>>
>>>>>> Steve Lin (3):
>>>>>>   devlink: Add config parameter get/set operations
>>>>>>   bnxt: Move generic devlink code to new file
>>>>>>   bnxt: Add devlink support for config get/set
>>>>>>
>>>>>
>>>>>Is the goal here to move all ethtool operations to devlink (I saw
>>some
>>>>>attrs related to speed etc). ?.
>>>>>We do need to move ethtool attrs to netlink and devlink is a good
>>>>>place (and of-course leave the current ethtool api around for
>>backward
>>>>>compatibility).
>>>>
>>>> We need to make sure we are not moving things to devlink which don't
>>>> belong there. All options that use "netdev" as a handle should go
>>into
>>>> rtnetlink instead.
>>>>
>>>
>>>Any reason you want to keep that restriction ?.
>>>FWIS, devlink is a driver api just like ethtool is.
>>>and ethtool needs to move to netlink soon...and It would be better to
>>>not put the rtnl_lock burden on ethtool driver operations. Instead of
>>>adding yet another driver api, extending devlink seems like a great
>>>fit to me.
>>
>>Hmm, the original purpose of devlink was to obtain iface for things
>>that
>>could not use "netdev" as a handle. I try to stick with it as we
>>already
>>have iface for things that could use "netdev" as a handle - rtnetlink.
>>
>>Not sure we want to go this way and add "netdev"-handle things into
>>devlink. Thoughts?
>
> In the current situation where we have ethtool and devlink operating sepa=
rately on different objects as entry points to the kernel, I agree with tha=
t design.
>
> Once we move ethtool (or however we name its successor) over to netlink t=
here is an opportunity for accessing objects that do and do not have a netd=
evice representor today (e.g: management ports on switches) with the same i=
nterface, and devlink could be used for that.
>
> In terms of compatibility though we should have a pseudo generic layer th=
at can take ethtool ioctl() and transform that into a netlink message and t=
hen call back down to drivers with the existing ethtool_ops that are implem=
ented. It is reasonably simple to use coccinelle to update these ethtool_op=
s with possibly updated signatures to support netlink attributes and whatno=
t,

ack, that sounds like a good approach.

> but forcing drivers to quit doing ethtool_ops entitely and implement new =
sets of "ethtool over netlink" ops is a non starter IMHO.

correct, nobody disagrees with that point.
