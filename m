From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 0/3] Adding config get/set to devlink
Date: Thu, 12 Oct 2017 11:59:19 -0700 (PDT)
Message-ID: <20171012.115919.1264476300111721032.davem@davemloft.net>
References: <1507815262-33294-1-git-send-email-steven.lin1@broadcom.com>
        <CAJieiUjuKtmYDZ5-7UjYkWFJuMGu2gajhziLQKAZLTz6g63f2A@mail.gmail.com>
        <20171012144032.GG14672@nanopsycho>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, steven.lin1@broadcom.com,
        netdev@vger.kernel.org, jiri@mellanox.com,
        michael.chan@broadcom.com, linux-pci@vger.kernel.org,
        linville@tuxdriver.com, gospo@broadcom.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55012 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751937AbdJLS7U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 14:59:20 -0400
In-Reply-To: <20171012144032.GG14672@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 12 Oct 2017 16:40:32 +0200

> Thu, Oct 12, 2017 at 04:35:10PM CEST, roopa@cumulusnetworks.com wrote:
>>On Thu, Oct 12, 2017 at 6:34 AM, Steve Lin <steven.lin1@broadcom.com> wrote:
>>> Adds a devlink command for getting & setting device configuration
>>> parameters, and enumerates a bunch of those parameters as devlink
>>> attributes.  Also introduces an attribute that can be set by a
>>> driver to indicate that the config change doesn't take effect
>>> until the next restart (as in the case of the bnxt driver changes
>>> in this patchset, for which all the configuration changes affect NVM
>>> only, and aren't loaded until the next restart.)
>>>
>>> bnxt driver patches make use of these new devlink cmds/attributes.
>>>
>>> Steve Lin (3):
>>>   devlink: Add config parameter get/set operations
>>>   bnxt: Move generic devlink code to new file
>>>   bnxt: Add devlink support for config get/set
>>>
>>
>>Is the goal here to move all ethtool operations to devlink (I saw some
>>attrs related to speed etc). ?.
>>We do need to move ethtool attrs to netlink and devlink is a good
>>place (and of-course leave the current ethtool api around for backward
>>compatibility).
> 
> We need to make sure we are not moving things to devlink which don't
> belong there. All options that use "netdev" as a handle should go into
> rtnetlink instead.

I agree.  Let's keep devlink what is was created for, which is situations
where we don't have a netdev as the object to work upon.
