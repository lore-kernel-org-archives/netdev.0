From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC 0/3] Adding config get/set to devlink
Date: Fri, 13 Oct 2017 09:08:23 +0200
Message-ID: <20171013070823.GE1952@nanopsycho.orion>
References: <CAJieiUiFmBr72yYP9VNtm0VBTNjJcA6Lj5nHJNBjDBC4moxE2A@mail.gmail.com>
 <20171012150419.GI14672@nanopsycho>
 <24E5DE7C-A401-48BF-BF80-673ACC38FBBE@gmail.com>
 <20171012.120650.1063812043202847517.davem@davemloft.net>
 <21ab4a5d-0b6a-7976-7bf0-acd334f2613f@gmail.com>
 <CA+Jmh7Em0ZjN0y3FSk1yBhOtPKvFBnJCVA97oZZb7cgXXF_aUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Michael Chan <michael.chan@broadcom.com>,
        linux-pci@vger.kernel.org, John Linville <linville@tuxdriver.com>,
        Andy Gospodarek <gospo@broadcom.com>
To: Steve Lin <steven.lin1@broadcom.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+Jmh7Em0ZjN0y3FSk1yBhOtPKvFBnJCVA97oZZb7cgXXF_aUA@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thu, Oct 12, 2017 at 10:12:31PM CEST, steven.lin1@broadcom.com wrote:
>On Thu, Oct 12, 2017 at 3:20 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> On 10/12/2017 12:06 PM, David Miller wrote:
>>> From: Florian Fainelli <f.fainelli@gmail.com>
>>> Date: Thu, 12 Oct 2017 08:43:59 -0700
>>>
>>>> Once we move ethtool (or however we name its successor) over to
>>>> netlink there is an opportunity for accessing objects that do and do
>>>> not have a netdevice representor today (e.g: management ports on
>>>> switches) with the same interface, and devlink could be used for
>>>> that.
>>>
>>> That is an interesting angle for including this in devlink.
>>>
>>> I'm not so sure what to do about this.
>>>
>>> One suggestion is that devlink is used for getting ethtool stats for
>>> objects lacking netdev representor's, and a new genetlink family is
>>> used for netdev based ethtool.
>>
>> Right, I was also thinking along those lines that we we would have a new
>> generic netlink family for ethtool to support ethtool over netlink.
>>
>>>
>>> I think it's important that we don't expand the scope of devlink
>>> beyond what it was originally designed for.
>>
>> It seems to me like devlink is well defined in what it is not for: it is
>> not meant to be used for any object that is/has a net_device, but it is
>> not well defined for what it can offer to these non network devices. For
>> instance, we have a tremendous amount of operations that are extremely
>> specific to its single user(s) such as mlx5 and mlxsw.
>>
>> For instance, I am not sure how the buffer reservation scheme can be
>> generalized, and this is always the tricky part with a single user
>> facility in that you try to generalize the best you can based on the HW
>> you know. This is not a criticism or meant to be anything negative, this
>> just happens to be the case, and we did not have anything better.
>>
>> So maybe the first thing is to clarify what devlink operations can and
>> should be and what they are absolutely not allowed to cover. We should
>> also clarify whether a generic set/get that Steven is proposing is
>> something that we tolerate, or whether there should be specific function
>> pointers implemented for each attribute, which would be more in line
>> with what has been done thus far.
>
>Hi Florian,
>
>Some of this is subjective, of course, but just to clarify, it did
>seem like implementing a new devlink_op function pointer per attribute
>might be more consistent with what's been done so far.  But for code
>reuse purposes - i.e. to avoid replicating essentially the same
>function for each of the 30+ config attributes - I elected to just
>implement a single generic get and set devlink_op.

Also, it this case, unlike any existing cmds, the config options are
all permanent, written in hw. I think it is fine to have one set
of get/set cmd to handle them all at once. Same family.
