From: Steve Lin <steven.lin1@broadcom.com>
Subject: Re: [RFC 0/3] Adding config get/set to devlink
Date: Thu, 12 Oct 2017 10:45:33 -0400
Message-ID: <CA+Jmh7GOo4K8gpyhQ8kceFtpNuASp89WYi0NR8AaoXncTCAksQ@mail.gmail.com>
References: <1507815262-33294-1-git-send-email-steven.lin1@broadcom.com> <CAJieiUjuKtmYDZ5-7UjYkWFJuMGu2gajhziLQKAZLTz6g63f2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        linux-pci@vger.kernel.org,
        "John W. Linville" <linville@tuxdriver.com>,
        Andy Gospodarek <gospo@broadcom.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f180.google.com ([209.85.216.180]:49288 "EHLO
        mail-qt0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753148AbdJLOpz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 10:45:55 -0400
Received: by mail-qt0-f180.google.com with SMTP id k31so14034514qta.6
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 07:45:55 -0700 (PDT)
In-Reply-To: <CAJieiUjuKtmYDZ5-7UjYkWFJuMGu2gajhziLQKAZLTz6g63f2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Roopa,

The attributes added in this patchset are not really the same type as
ethtool - these are more device configuration type attributes.  The
speeds you saw, for example, affect the pre-OS [i.e. PXE boot time]
configuration for a port, and aren't run-time speed changes on a given
netdev like ethtool configures.  As Jiri mentioned, I will add some
comments to better describe each of the attributes.

So I don't think there's much duplication here with ethtool.

That said, there also shouldn't be anything in the patchset that would
preclude some future migration of ethtool settings to using devlink or
rtnetlink API.

Steve

On Thu, Oct 12, 2017 at 10:35 AM, Roopa Prabhu
<roopa@cumulusnetworks.com> wrote:
> On Thu, Oct 12, 2017 at 6:34 AM, Steve Lin <steven.lin1@broadcom.com> wrote:
>> Adds a devlink command for getting & setting device configuration
>> parameters, and enumerates a bunch of those parameters as devlink
>> attributes.  Also introduces an attribute that can be set by a
>> driver to indicate that the config change doesn't take effect
>> until the next restart (as in the case of the bnxt driver changes
>> in this patchset, for which all the configuration changes affect NVM
>> only, and aren't loaded until the next restart.)
>>
>> bnxt driver patches make use of these new devlink cmds/attributes.
>>
>> Steve Lin (3):
>>   devlink: Add config parameter get/set operations
>>   bnxt: Move generic devlink code to new file
>>   bnxt: Add devlink support for config get/set
>>
>
> Is the goal here to move all ethtool operations to devlink (I saw some
> attrs related to speed etc). ?.
> We do need to move ethtool attrs to netlink and devlink is a good
> place (and of-course leave the current ethtool api around for backward
> compatibility).
