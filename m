From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next 3/6] mlxsw: spectrum_router: Use FIB
 notifications instead of switchdev calls
Date: Thu, 22 Sep 2016 08:58:20 -0600
Message-ID: <5206ebd6-89c1-ec44-8b98-c5109ebe6140@cumulusnetworks.com>
References: <1474458794-5512-1-git-send-email-jiri@resnulli.us>
 <1474458794-5512-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, andy@greyhouse.net, f.fainelli@gmail.com,
        jhs@mojatatu.com, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, ivecera@redhat.com, kaber@trash.net,
        john@phrozen.org
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35508 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757521AbcIVO6Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 10:58:25 -0400
Received: by mail-pf0-f173.google.com with SMTP id z123so31504636pfz.2
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 07:58:25 -0700 (PDT)
In-Reply-To: <1474458794-5512-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/21/16 5:53 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Until now, in order to offload a FIB entry to HW we use switchdev op.
> However that has limits. Mainly in case we need to make the HW aware of
> all route prefixes configured in kernel. HW needs to know those in order
> to properly trap appropriate packets and pass the to kernel to do
> the forwarding. Abort mechanism is now handled within the mlxsw driver.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   9 +-
>  .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 386 ++++++++++++---------
>  .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |   9 -
>  3 files changed, 216 insertions(+), 188 deletions(-)
> 
> 


Make the move to fib notifiers and the removal of switchdev code separate patches. It will make the fib notifier change easier to follow.
