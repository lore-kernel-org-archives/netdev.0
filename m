From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC 0/3] Adding config get/set to devlink
Date: Thu, 12 Oct 2017 17:04:19 +0200
Message-ID: <20171012150419.GI14672@nanopsycho>
References: <1507815262-33294-1-git-send-email-steven.lin1@broadcom.com>
 <CAJieiUjuKtmYDZ5-7UjYkWFJuMGu2gajhziLQKAZLTz6g63f2A@mail.gmail.com>
 <20171012144032.GG14672@nanopsycho>
 <CAJieiUiFmBr72yYP9VNtm0VBTNjJcA6Lj5nHJNBjDBC4moxE2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Lin <steven.lin1@broadcom.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        michael.chan@broadcom.com, linux-pci@vger.kernel.org,
        "John W. Linville" <linville@tuxdriver.com>, gospo@broadcom.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:56600 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752454AbdJLPEV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 11:04:21 -0400
Received: by mail-wm0-f68.google.com with SMTP id l68so14186813wmd.5
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 08:04:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJieiUiFmBr72yYP9VNtm0VBTNjJcA6Lj5nHJNBjDBC4moxE2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 12, 2017 at 04:46:24PM CEST, roopa@cumulusnetworks.com wrote:
>On Thu, Oct 12, 2017 at 7:40 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Thu, Oct 12, 2017 at 04:35:10PM CEST, roopa@cumulusnetworks.com wrote:
>>>On Thu, Oct 12, 2017 at 6:34 AM, Steve Lin <steven.lin1@broadcom.com> wrote:
>>>> Adds a devlink command for getting & setting device configuration
>>>> parameters, and enumerates a bunch of those parameters as devlink
>>>> attributes.  Also introduces an attribute that can be set by a
>>>> driver to indicate that the config change doesn't take effect
>>>> until the next restart (as in the case of the bnxt driver changes
>>>> in this patchset, for which all the configuration changes affect NVM
>>>> only, and aren't loaded until the next restart.)
>>>>
>>>> bnxt driver patches make use of these new devlink cmds/attributes.
>>>>
>>>> Steve Lin (3):
>>>>   devlink: Add config parameter get/set operations
>>>>   bnxt: Move generic devlink code to new file
>>>>   bnxt: Add devlink support for config get/set
>>>>
>>>
>>>Is the goal here to move all ethtool operations to devlink (I saw some
>>>attrs related to speed etc). ?.
>>>We do need to move ethtool attrs to netlink and devlink is a good
>>>place (and of-course leave the current ethtool api around for backward
>>>compatibility).
>>
>> We need to make sure we are not moving things to devlink which don't
>> belong there. All options that use "netdev" as a handle should go into
>> rtnetlink instead.
>>
>
>Any reason you want to keep that restriction ?.
>FWIS, devlink is a driver api just like ethtool is.
>and ethtool needs to move to netlink soon...and It would be better to
>not put the rtnl_lock burden on ethtool driver operations. Instead of
>adding yet another driver api, extending devlink seems like a great
>fit to me.

Hmm, the original purpose of devlink was to obtain iface for things that
could not use "netdev" as a handle. I try to stick with it as we already
have iface for things that could use "netdev" as a handle - rtnetlink.

Not sure we want to go this way and add "netdev"-handle things into
devlink. Thoughts?
