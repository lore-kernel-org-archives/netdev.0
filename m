From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next 01/18] bridge: Export VLAN filtering state
Date: Fri, 26 May 2017 11:55:18 +0300
Message-ID: <b2edc91e-d7cf-a667-2b00-5722ed09a2a6@cumulusnetworks.com>
References: <20170526063740.8909-1-jiri@resnulli.us>
 <20170526063740.8909-2-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        stephen@networkplumber.org
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:35100 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967663AbdEZIzG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 04:55:06 -0400
Received: by mail-wm0-f45.google.com with SMTP id b84so121667052wmh.0
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 01:55:05 -0700 (PDT)
In-Reply-To: <20170526063740.8909-2-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/26/17 9:37 AM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> It's useful for drivers supporting bridge offload to be able to query
> the bridge's VLAN filtering state.
> 
> Currently, upon enslavement to a bridge master, the offloading driver
> will only learn about the bridge's VLAN filtering state after the bridge
> device was already linked with its slave.
> 
> Being able to query the bridge's VLAN filtering state allows such
> drivers to forbid enslavement in case resource couldn't be allocated for
> a VLAN-aware bridge and also choose the correct initialization routine
> for the enslaved port, which is dependent on the bridge type.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>   include/linux/if_bridge.h | 9 +++++++++
>   net/bridge/br_if.c        | 2 +-
>   net/bridge/br_mdb.c       | 4 ++--
>   net/bridge/br_netlink.c   | 2 +-
>   net/bridge/br_private.h   | 9 ---------
>   net/bridge/br_vlan.c      | 8 ++++++++
>   6 files changed, 21 insertions(+), 13 deletions(-)
> 

I must say this bridge -> dev -> bridge looks weird from the bridge POV.
Since exports like this seem to be increasing I think it'd be nice to
make some API that can be queried instead of exporting symbols for each
bridge option or attribute. In this case maybe a simpler solution would've
been only a new exported symbol for external users.

The patch itself looks good to me.

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
