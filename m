From: Dan Carpenter <error27@gmail.com>
Subject: [smatch] re: bonding:delete lacp_fast from ad_bond_info
Date: Sat, 11 Jun 2011 11:12:14 +0300
Message-ID: <20110611081214.GA21427@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "open list:BONDING DRIVER" <netdev@vger.kernel.org>
To: panweiping3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:37241 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357Ab1FKIQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 04:16:28 -0400
Received: by pwi15 with SMTP id 15so1531539pwi.19
        for <netdev@vger.kernel.org>; Sat, 11 Jun 2011 01:16:28 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There was a dereference before a check added in 56d00c677de0a
"bonding:delete lacp_fast from ad_bond_info"

drivers/net/bonding/bond_3ad.c +1907 bond_3ad_bind_slave(7)
	warn: variable dereferenced before check 'bond'

  1900  int bond_3ad_bind_slave(struct slave *slave)
  1901  {
  1902          struct bonding *bond = bond_get_bond_by_slave(slave);
  1903          int lacp_fast = bond->params.lacp_fast;
                                ^^^^^^^^^^^^
	dereference.

  1904          struct port *port;
  1905          struct aggregator *aggregator;
  1906  
  1907          if (bond == NULL) {
                    ^^^^^^^^^^^^
	check.

  1908                  pr_err("%s: The slave %s is not attached to its bond\n",
  1909                         slave->dev->master->name, slave->dev->name);
  1910                  return -1;
  1911          }

regards,
dan carpenter
