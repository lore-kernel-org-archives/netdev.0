From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 3/6] mlxsw: spectrum_router: Use FIB
 notifications instead of switchdev calls
Date: Thu, 22 Sep 2016 17:05:51 +0200
Message-ID: <20160922150551.GE1830@nanopsycho.orion>
References: <1474458794-5512-1-git-send-email-jiri@resnulli.us>
 <1474458794-5512-4-git-send-email-jiri@resnulli.us>
 <5206ebd6-89c1-ec44-8b98-c5109ebe6140@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, linville@tuxdriver.com,
        andy@greyhouse.net, f.fainelli@gmail.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        ivecera@redhat.com, kaber@trash.net, john@phrozen.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35216 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933098AbcIVPFy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 11:05:54 -0400
Received: by mail-wm0-f65.google.com with SMTP id 133so14586405wmq.2
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 08:05:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5206ebd6-89c1-ec44-8b98-c5109ebe6140@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Sep 22, 2016 at 04:58:20PM CEST, dsa@cumulusnetworks.com wrote:
>On 9/21/16 5:53 AM, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Until now, in order to offload a FIB entry to HW we use switchdev op.
>> However that has limits. Mainly in case we need to make the HW aware of
>> all route prefixes configured in kernel. HW needs to know those in order
>> to properly trap appropriate packets and pass the to kernel to do
>> the forwarding. Abort mechanism is now handled within the mlxsw driver.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   9 +-
>>  .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 386 ++++++++++++---------
>>  .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |   9 -
>>  3 files changed, 216 insertions(+), 188 deletions(-)
>> 
>> 
>
>
>Make the move to fib notifiers and the removal of switchdev code separate patches. It will make the fib notifier change easier to follow.

Since I'm changing one iface by another, I don't see how I can split it.
