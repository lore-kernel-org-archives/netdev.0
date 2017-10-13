From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC 0/3] Adding config get/set to devlink
Date: Fri, 13 Oct 2017 09:11:21 +0200
Message-ID: <20171013071121.GF1952@nanopsycho.orion>
References: <CAJieiUiFmBr72yYP9VNtm0VBTNjJcA6Lj5nHJNBjDBC4moxE2A@mail.gmail.com>
 <20171012150419.GI14672@nanopsycho>
 <24E5DE7C-A401-48BF-BF80-673ACC38FBBE@gmail.com>
 <20171012.120650.1063812043202847517.davem@davemloft.net>
 <21ab4a5d-0b6a-7976-7bf0-acd334f2613f@gmail.com>
 <CAJieiUjK4CsBGT5_YidnEGk7mCVYYO_8S0xcsv+XfaW=amGCaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        Steve Lin <steven.lin1@broadcom.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Michael Chan <michael.chan@broadcom.com>,
        linux-pci@vger.kernel.org,
        "John W. Linville" <linville@tuxdriver.com>,
        Andy Gospodarek <gospo@broadcom.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:50494 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750924AbdJMHLW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 03:11:22 -0400
Received: by mail-wm0-f67.google.com with SMTP id u138so18745982wmu.5
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 00:11:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJieiUjK4CsBGT5_YidnEGk7mCVYYO_8S0xcsv+XfaW=amGCaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 12, 2017 at 11:53:56PM CEST, roopa@cumulusnetworks.com wrote:
>On Thu, Oct 12, 2017 at 12:20 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
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
>
>new api is fine by me. The reason for suggesting devlink was because
>some of the devlink
>port_* ops are close to ethtool ops that can operate on a port/netdev.
>eg split_port could be a netdev operation
>unless you want to split before the netdev is created.

Let me correct you. The split is always devlink_port operation. In some
cases however when there is a mapping between devlink_port and netdev,
userspace part could translate netdev->devlink_port.


>
>There are some ops in devlink which are global hw parameters and not
>specific to a port, those fit perfectly with
>devlinks original goal.

There are 2 handles from the very beginning:
1) devlink - asic-wide handle
2) devlink_port - port handle
