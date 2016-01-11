From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] mlxsw: spectrum: Add FDB lock to prevent session
 interleaving
Date: Mon, 11 Jan 2016 00:21:03 -0500 (EST)
Message-ID: <20160111.002103.979291218776108297.davem@davemloft.net>
References: <1452414736-3571-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33175 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbcAKFVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 00:21:07 -0500
In-Reply-To: <1452414736-3571-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sun, 10 Jan 2016 09:32:16 +0100

> From: Ido Schimmel <idosch@mellanox.com>
> 
> Dumping the FDB (invoked with a process context) or handling FDB
> notifications (polled periodicly in delayed work) might each entail
> multiple EMAD transcations due to the number of entries.
> 
> While we only allow one EMAD transaction at a time, there is nothing
> stopping the dump and notification processing sessions from
> interleaving. However, this is forbidden by the hardware, so we need to
> make sure only one of these sessions can run at a time.
> 
> Solve this by adding a mutex ('fdb_lock'), as both kernel threads can
> sleep while waiting for the response EMAD.
> 
> Fixes: 56ade8fe3f ("mlxsw: spectrum: Add initial support for Spectrum ASIC")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Jiri, I noticed you submitted both a net and a net-next variant of
this same fix.  Please don't ever do that.

it's easiest if I just apply the 'net' variant and handle the merge
issues when I pull 'net' into 'net-next', so that how I'm going to
handle this change.

Applied, thanks.
