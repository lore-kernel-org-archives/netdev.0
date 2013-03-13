From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: don't call update_speed_duplex() under
 spinlocks
Date: Wed, 13 Mar 2013 04:53:36 -0400 (EDT)
Message-ID: <20130313.045336.984924610426807326.davem@davemloft.net>
References: <1363105892-3172-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lkml@tlinx.org, eric.dumazet@gmail.com,
	fubar@us.ibm.com, jeffrey.t.kirsher@intel.com,
	xiyou.wangcong@gmail.com, andy@greyhouse.net
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40163 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932572Ab3CMIxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 04:53:25 -0400
In-Reply-To: <1363105892-3172-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Tue, 12 Mar 2013 17:31:32 +0100

> bond_update_speed_duplex() might sleep while calling underlying slave's
> routines. Move it out of atomic context in bond_enslave() and remove it
> from bond_miimon_commit() - it was introduced by commit 546add79, however
> when the slave interfaces go up/change state it's their responsibility to
> fire NETDEV_UP/NETDEV_CHANGE events so that bonding can properly update
> their speed.
> 
> I've tested it on all combinations of ifup/ifdown, autoneg/speed/duplex
> changes, remote-controlled and local, on (not) MII-based cards. All changes
> are visible.
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Applied, thanks.
