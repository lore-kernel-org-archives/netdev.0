From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next v2 05/19] net: bridge: Add support for notifying
 devices about FDB add/del
Date: Thu, 8 Jun 2017 12:25:44 +0300
Message-ID: <008458f1-d778-8932-700a-8ad8d0819c38@cumulusnetworks.com>
References: <20170608064428.4785-1-jiri@resnulli.us>
 <20170608064428.4785-6-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, ivecera@redhat.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:35903 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751299AbdFHJZr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 05:25:47 -0400
Received: by mail-wm0-f53.google.com with SMTP id 7so133800739wmo.1
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 02:25:47 -0700 (PDT)
In-Reply-To: <20170608064428.4785-6-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/17 09:44, Jiri Pirko wrote:
> From: Arkadi Sharshevsky <arkadis@mellanox.com>
> 
> Currently the bridge doesn't notify the underlying devices about new
> FDBs learned. The FDB sync is placed on the switchdev notifier chain
> because devices may potentially learn FDB that are not directly related
> to their ports, for example:
> 
> 1. Mixed SW/HW bridge - FDBs that point to the ASICs external devices
>                         should be offloaded as CPU traps in order to
> 			perform forwarding in slow path.
> 2. EVPN - Externally learned FDBs for the vtep device.
> 
> Notification is sent only about static FDB add/del. This is done due
> to fact that currently this is the only scenario supported by switch
> drivers.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |  2 +-
>  drivers/net/ethernet/rocker/rocker_ofdpa.c         |  4 +--
>  include/net/switchdev.h                            |  6 ++--
>  net/bridge/br.c                                    |  4 +--
>  net/bridge/br_fdb.c                                |  2 ++
>  net/bridge/br_private.h                            |  7 +++++
>  net/bridge/br_switchdev.c                          | 33 ++++++++++++++++++++++
>  7 files changed, 51 insertions(+), 7 deletions(-)
> 

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
