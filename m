From: Jiri Pirko <jpirko@redhat.com>
Subject: [question] bond_set_slave_inactive_flags
Date: Tue, 1 Mar 2011 08:43:19 +0100
Message-ID: <20110301074318.GF2855@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7461 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755595Ab1CAHnW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 02:43:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay,

Looking at function bond_set_slave_inactive_flags:

static inline void bond_set_slave_inactive_flags(struct slave *slave)
{
        struct bonding *bond = netdev_priv(slave->dev->master);
        if (!bond_is_lb(bond))
                slave->state = BOND_STATE_BACKUP;
        if (!bond->params.all_slaves_active)
                slave->dev->priv_flags |= IFF_SLAVE_INACTIVE;
        if (slave_do_arp_validate(bond, slave))
                slave->dev->priv_flags |= IFF_SLAVE_NEEDARP;
}

Why BOND_STATE_BACKUP is set only for non-lb bonds?
This was introduced by 8f903c708fcc2b579ebf16542bf6109bad593a1d but
I do not see why.

Thanks for reply in advance.

Jirka
