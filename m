From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: bonding: remove entries for master_ip and vlan_ip and query
 devices instead
Date: Thu, 25 Oct 2012 15:29:09 +0300
Message-ID: <20121025122908.GA20595@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:23869 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756122Ab2JYM3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 08:29:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ Sort of old, but apparently I didn't email about this in March ].

Hello Andy Gospodarek,

This is a semi-automatic email about new static checker warnings.

The patch eaddcd76903c: "bonding: remove entries for master_ip and 
vlan_ip and query devices instead" from Mar 22, 2012, leads to the 
following Smatch complaint:

drivers/net/bonding/bond_main.c:2703 bond_arp_send_all()
	 warn: variable dereferenced before check 'vlan_dev' (see line 2697)

drivers/net/bonding/bond_main.c
  2696					vlan_id = vlan->vlan_id;
                                        ^^^^^^^^^^
If vlan_id is non-zero it means we went hit this assignment.

  2697					pr_debug("basa: vlan match on %s %d\n",
  2698					       vlan_dev->name, vlan_id);
                                               ^^^^^^^^^^
Old dereference.

  2699					break;
  2700				}
  2701			}
  2702	
  2703			if (vlan_id && vlan_dev) {
                                       ^^^^^^^^
New check.

  2704				ip_rt_put(rt);
  2705				addr = bond_confirm_addr(vlan_dev, targets[i], 0);

regards,
dan carpenter
