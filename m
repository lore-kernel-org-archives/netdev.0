From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next 03/10] ipv4: fib_rules: Dump FIB rules when
 registering FIB notifier
Date: Mon, 13 Mar 2017 08:52:45 -0600
Message-ID: <fb57e851-4edf-5753-1036-2505314983ea@cumulusnetworks.com>
References: <1489390535-2566-1-git-send-email-jiri@resnulli.us>
 <1489390713-2634-1-git-send-email-jiri@resnulli.us>
 <1489390713-2634-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        shm@cumulusnetworks.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, lorenzo@google.com,
        mateusz.bajorski@nokia.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:35682 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751920AbdCMOws (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 10:52:48 -0400
Received: by mail-pg0-f43.google.com with SMTP id b129so64555867pgc.2
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 07:52:47 -0700 (PDT)
In-Reply-To: <1489390713-2634-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/13/17 1:38 AM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> In commit c3852ef7f2f8 ("ipv4: fib: Replay events when registering FIB
> notifier") we dumped the FIB tables and replayed the events to the
> passed notification block.
> 
> However, we merely sent a RULE_ADD notification in case custom rules
> were in use. As explained in previous patches, this approach won't work
> anymore. Instead, we should notify the caller about all the FIB rules
> and let it act accordingly.
> 
> Upon registration to the FIB notification chain, replay a RULE_ADD
> notification for each programmed FIB rule, custom or not. The integrity
> of the dump is ensured by the mechanism introduced in the above
> mentioned commit.
> 
> Prevent regressions by making sure current listeners correctly sanitize
> the notified rules.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlxsw/Kconfig           |  1 +
>  drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 11 ++++++++++-
>  drivers/net/ethernet/rocker/Kconfig                   |  2 +-
>  drivers/net/ethernet/rocker/rocker_main.c             | 15 +++++++++++++--
>  net/ipv4/fib_rules.c                                  | 19 ++++++++++++++++---
>  5 files changed, 41 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlxsw/Kconfig b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
> index ef23eae..a549a89 100644
> --- a/drivers/net/ethernet/mellanox/mlxsw/Kconfig
> +++ b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
> @@ -73,6 +73,7 @@ config MLXSW_SWITCHX2
>  config MLXSW_SPECTRUM
>  	tristate "Mellanox Technologies Spectrum support"
>  	depends on MLXSW_CORE && MLXSW_PCI && NET_SWITCHDEV && VLAN_8021Q
> +	depends on IP_MULTIPLE_TABLES
>  	depends on PSAMPLE || PSAMPLE=n
>  	select PARMAN
>  	default m

Why require multiple tables just b/c the h/w has the ability to support
multiple tables?
