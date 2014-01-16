From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 1/2] bonding: add sysfs /slave dir for bond
 slave devices.
Date: Thu, 16 Jan 2014 19:44:41 +0100
Message-ID: <20140116184441.GB24396@redhat.com>
References: <20140116055434.32220.89883.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, shm@cumulusnetworks.com
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22651 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750874AbaAPSrk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 13:47:40 -0500
Content-Disposition: inline
In-Reply-To: <20140116055434.32220.89883.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 15, 2014 at 09:54:34PM -0800, Scott Feldman wrote:
...snip...
>+	res = bond_sysfs_slave_add(new_slave);
>+	if (res) {
>+		pr_debug("Error %d calling bond_sysfs_slave_add\n", res);
>+		goto err_upper_unlink;
>+	}
>+
> 	bond->slave_cnt++;
> 	bond_compute_features(bond);
> 	bond_set_carrier(bond);
>@@ -1595,6 +1617,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
> 	return 0;
>
> /* Undo stages on error */
>+err_upper_unlink:
>+	bond_upper_dev_unlink(bond_dev, slave_dev);
>+
> err_unregister:
> 	netdev_rx_handler_unregister(slave_dev);
>

In case bond_sysfs_slave_add() creates the kobject, but fails to create the
attributes, we'll end up with a mem leak, as we don't do kobject_put() on
it.
