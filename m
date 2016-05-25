From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] team: don't call netdev_change_features under
 team->lock
Date: Wed, 25 May 2016 12:58:49 -0700 (PDT)
Message-ID: <20160525.125849.1174323879157051172.davem@davemloft.net>
References: <1464204112-4044-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42735 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbcEYT6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 15:58:51 -0400
In-Reply-To: <1464204112-4044-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Wed, 25 May 2016 21:21:52 +0200

> The team_device_event() notifier calls team_compute_features() to fix
> vlan_features under team->lock to protect team->port_list. The problem is
> that subsequent __team_compute_features() calls netdev_change_features()
> to propagate vlan_features to upper vlan devices while team->lock is still
> taken. This can lead to deadlock when NETIF_F_LRO is modified on lower
> devices or team device itself.
> 
> Example:
> The team0 as active backup with eth0 and eth1 NICs. Both eth0 & eth1 are
> LRO capable and LRO is enabled. Thus LRO is also enabled on team0.
> 
> The command 'ethtool -K team0 lro off' now hangs due to this deadlock:
 ...
> The bug is present in team from the beginning but it appeared after the commit
> fd867d5 (net/core: generic support for disabling netdev features down stack)
> that adds synchronization of features with lower devices.
> 
> Fixes: fd867d5 (net/core: generic support for disabling netdev features down stack)
> Cc: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied and queued up for -stable, thanks.
