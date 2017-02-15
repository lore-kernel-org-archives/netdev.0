From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: neigh: Fix netevent
 NETEVENT_DELAY_PROBE_TIME_UPDATE notification
Date: Wed, 15 Feb 2017 12:39:34 -0500 (EST)
Message-ID: <20170215.123934.1347540582194909272.davem@davemloft.net>
References: <20170215000036.qzzglyaasqfy7vsn@linux.fritz.box>
        <20170215065925.GA11243@splinter.mtl.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: suse-tux@gmx.de, netdev@vger.kernel.org
To: idosch@idosch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35658 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751934AbdBORjf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 12:39:35 -0500
In-Reply-To: <20170215065925.GA11243@splinter.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@idosch.org>
Date: Wed, 15 Feb 2017 08:59:25 +0200

> On Wed, Feb 15, 2017 at 01:00:36AM +0100, Marcus Huewe wrote:
>> When setting a neigh related sysctl parameter, we always send a
>> NETEVENT_DELAY_PROBE_TIME_UPDATE netevent. For instance, when
>> executing
>> 
>> 	sysctl net.ipv6.neigh.wlp3s0.retrans_time_ms=2000
>> 
>> a NETEVENT_DELAY_PROBE_TIME_UPDATE netevent is generated.
>> 
>> This is caused by commit 2a4501ae18b5 ("neigh: Send a
>> notification when DELAY_PROBE_TIME changes"). According to the
>> commit's description, it was intended to generate such an event
>> when setting the "delay_first_probe_time" sysctl parameter.
>> 
>> In order to fix this, only generate this event when actually
>> setting the "delay_first_probe_time" sysctl parameter. This fix
>> should not have any unintended side-effects, because all but one
>> registered netevent callbacks check for other netevent event
>> types (the registered callbacks were obtained by grepping for
>> "register_netevent_notifier"). The only callback that uses the
>> NETEVENT_DELAY_PROBE_TIME_UPDATE event is
>> mlxsw_sp_router_netevent_event() (in
>> drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c): in case
>> of this event, it only accesses the DELAY_PROBE_TIME of the
>> passed neigh_parms.
>> 
>> Signed-off-by: Marcus Huewe <suse-tux@gmx.de>
> 
> Fixes: 2a4501ae18b5 ("neigh: Send a notification when DELAY_PROBE_TIME changes")
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>

Applied and queued up for -stable, thanks everyone.
