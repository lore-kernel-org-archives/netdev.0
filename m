From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [RFC 0/3] Adding config get/set to devlink
Date: Fri, 13 Oct 2017 21:21:51 -0700
Message-ID: <CAJieiUivmAzJ2rxaf44HxOJ2u1nXUuFMkGSkjK2zfy3JKyfxFA@mail.gmail.com>
References: <CAJieiUiFmBr72yYP9VNtm0VBTNjJcA6Lj5nHJNBjDBC4moxE2A@mail.gmail.com>
 <20171012150419.GI14672@nanopsycho> <24E5DE7C-A401-48BF-BF80-673ACC38FBBE@gmail.com>
 <20171012.120650.1063812043202847517.davem@davemloft.net> <21ab4a5d-0b6a-7976-7bf0-acd334f2613f@gmail.com>
 <CAJieiUjK4CsBGT5_YidnEGk7mCVYYO_8S0xcsv+XfaW=amGCaQ@mail.gmail.com> <20171013071121.GF1952@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        Steve Lin <steven.lin1@broadcom.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Michael Chan <michael.chan@broadcom.com>,
        linux-pci@vger.kernel.org,
        "John W. Linville" <linville@tuxdriver.com>,
        Andy Gospodarek <gospo@broadcom.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20171013071121.GF1952@nanopsycho.orion>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 13, 2017 at 12:11 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Thu, Oct 12, 2017 at 11:53:56PM CEST, roopa@cumulusnetworks.com wrote:
>>On Thu, Oct 12, 2017 at 12:20 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>> On 10/12/2017 12:06 PM, David Miller wrote:
>>>> From: Florian Fainelli <f.fainelli@gmail.com>
>>>> Date: Thu, 12 Oct 2017 08:43:59 -0700
>>>>
>>>>> Once we move ethtool (or however we name its successor) over to
>>>>> netlink there is an opportunity for accessing objects that do and do
>>>>> not have a netdevice representor today (e.g: management ports on
>>>>> switches) with the same interface, and devlink could be used for
>>>>> that.
>>>>
>>>> That is an interesting angle for including this in devlink.
>>>>
>>>> I'm not so sure what to do about this.
>>>>
>>>> One suggestion is that devlink is used for getting ethtool stats for
>>>> objects lacking netdev representor's, and a new genetlink family is
>>>> used for netdev based ethtool.
>>>
>>> Right, I was also thinking along those lines that we we would have a new
>>> generic netlink family for ethtool to support ethtool over netlink.
>>
>>new api is fine by me. The reason for suggesting devlink was because
>>some of the devlink
>>port_* ops are close to ethtool ops that can operate on a port/netdev.
>>eg split_port could be a netdev operation
>>unless you want to split before the netdev is created.
>
> Let me correct you. The split is always devlink_port operation. In some
> cases however when there is a mapping between devlink_port and netdev,
> userspace part could translate netdev->devlink_port.

yes, thats what i was trying to hint..that in some cases devlink_port
can already be mapped to a netdev.

>
>
>>
>>There are some ops in devlink which are global hw parameters and not
>>specific to a port, those fit perfectly with
>>devlinks original goal.
>
> There are 2 handles from the very beginning:
> 1) devlink - asic-wide handle
> 2) devlink_port - port handle

yep, i know that...and i was not trying to say that is a bad thing.

I think we will end up with devlink_port operations that could also be
done on a netdev down the lane. And, we may have to then argue where
an attribute will go. Hence my suggestion on classifying the api by
the target (driver in this case vs kernel networking for rtnetlink).
If you take netdev out of the picture, the port attributes that
devlink tries to set are similar to the ethtool port attributes today.
Also, it seemed like the new port attributes set api (proposed in this
thread) was close to the ethtool attributes set. Having all link hw
attributes in the same tool/api has  advantages. I have no plans to
move anything yet...so if the general preference is to keep devlink
netdev free for now, thats fine.
