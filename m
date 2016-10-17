From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 02/11] net: Introduce new api for walking
 upper and lower devices
Date: Mon, 17 Oct 2016 10:42:00 -0400 (EDT)
Message-ID: <20161017.104200.2266025643403507437.davem@davemloft.net>
References: <1476494931-31813-1-git-send-email-dsa@cumulusnetworks.com>
        <1476494931-31813-3-git-send-email-dsa@cumulusnetworks.com>
        <20161017052121.2322279d@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, jiri@mellanox.com, netdev@vger.kernel.org,
        dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, linux-rdma@vger.kernel.org,
        j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56128 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933005AbcJQOmC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 10:42:02 -0400
In-Reply-To: <20161017052121.2322279d@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 17 Oct 2016 05:21:21 -0700

> You should write this more succinctly as:
> 
> static bool __netdev_has_upper_dev(struct net_device *upper_dev, void *data)
> {
> 	struct net_device *dev = data;
> 
> 	return upper_dev == dev;
> }
> 
> bool netdev_has_upper_dev_all_rcu(struct net_device *dev,
> 				  struct net_device *upper_dev)
> {
> 	return netdev_walk_all_upper_dev_rcu(dev,
> 			__netdev_has_upper_dev, upper_dev);
> }
> 
> No if/else needed. No cast of void * ptr need. Use const if possible?

Agreed.
