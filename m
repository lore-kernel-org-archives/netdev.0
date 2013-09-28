From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] bonding: remove bond_next_slave()
Date: Sat, 28 Sep 2013 15:29:09 -0700 (PDT)
Message-ID: <20130928.152909.1883927861250097562.davem@davemloft.net>
References: <1380291125-5671-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@redhat.com,
	bhutchings@solarflare.com, fubar@us.ibm.com, andy@greyhouse.net
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33827 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755084Ab3I1WWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 18:22:11 -0400
In-Reply-To: <1380291125-5671-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Fri, 27 Sep 2013 16:11:56 +0200

> (on top of "[PATCH net-next 0/2] bonding: fix 3ad slave (de)init" - the
> patchset is essential)
> 
> Hi,
> 
> As Ben Hutchings and Nikolay Aleksandrov correctly noted -
> bond_next_slave() already is not O(1), but rather O(n), so it's only useful
> for one-off operations and shouldn't be used widely - for example, for list
> traversal, which will take O(n^2) time, which will be disastrous for any
> hot path with a large number of slaves.
> 
> Currently, bond_next_slave() is used several times in 802.3ad and for
> seq_read - bond_info_seq_next().
> 
> The 802.3ad part uses it only in constructs like:
> 
> for (X = __get_first_X(); X; X = __get_next_X()) {
> 
> where __get_next_X() uses bond_next_slave().
> 
> This for can (and should) actually be replaced by the standard
> 
> bond_for_each_slave(bond, slave, iter) {
> 	X = __get_X_by_slave(slave);
> 
> it's faster, easier to read, debug and maintain. Also, removes a lot of
> code lines.
> 
> After replacing it, the only user of bond_next_slave() is
> bond_info_seq_next() - which can, actually, implement it by itself, and not
> call another function.
> 
> So, that way, we can completely remove the bond_next_slave(), cleanup and
> optimize a bit.
> 
> p.s. the 802.3ad code is horrible, both style-wise and from the logical
> point of view - so I've decided to *not* change anything except that what
> this patch is intended to provide. The cleanup and some refactoring should
> be done in another patchset, which I've began to work on already.
> 
> Thank you!
> 
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Also applied, thanks.
