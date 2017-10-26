From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 2/4] net: sched: move the can_offload check from
 binding phase to rule insertion phase
Date: Thu, 26 Oct 2017 08:07:48 +0200
Message-ID: <20171026060748.GA1928@nanopsycho.orion>
References: <20171025143500.28973-1-jiri@resnulli.us>
 <20171025143500.28973-3-jiri@resnulli.us>
 <20171026.100131.1516530767097739079.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:45893 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750949AbdJZGHu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 02:07:50 -0400
Received: by mail-wm0-f66.google.com with SMTP id q124so5644115wmb.0
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 23:07:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171026.100131.1516530767097739079.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 26, 2017 at 03:01:31AM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Wed, 25 Oct 2017 16:34:58 +0200
>
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> This restores the original behaviour before the block callbacks were
>> introduced. Allow the drivers to do binding of block always, no matter
>> if the NETIF_F_HW_TC feature is on or off. Move the check to the block
>> callback which is called for rule insertion.
>> 
>> Reported-by: Alexander Duyck <alexander.duyck@gmail.com>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>
>I agree with Jakub's feedback, if every callback has to make this check
>why not just do it in the core where the callback is invoked?

We cannot add it to the core. The idea of the block callbacks is to get
independent of the "dev". For the block sharing, driver registers one
block callback for multiple devs. Core has no access to "dev".
