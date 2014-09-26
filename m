From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvtap: Fix race between device delete and open.
Date: Fri, 26 Sep 2014 15:21:27 -0400 (EDT)
Message-ID: <20140926.152127.303982560731423514.davem@davemloft.net>
References: <1411418057-18937-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com, mst@redhat.com,
	jasowang@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753428AbaIZTVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 15:21:30 -0400
In-Reply-To: <1411418057-18937-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Mon, 22 Sep 2014 16:34:17 -0400

> In macvtap device delete and open calls can race and
> this causes a list curruption of the vlan queue_list.
> 
> The race intself is triggered by the idr accessors
> that located the vlan device.  The device is stored
> into and removed from the idr under both an rtnl and
> a mutex.  However, when attempting to locate the device
> in idr, only a mutex is taken.  As a result, once cpu
> perfoming a delete may take an rtnl and wait for the mutex,
> while another cput doing an open() will take the idr
> mutex first to fetch the device pointer and later take
> an rtnl to add a queue for the device which may have
> just gotten deleted.
> 
> With this patch, we now hold the rtnl for the duration
> of the macvtap_open() call thus making sure that
> open will not race with delete.
> 
> CC: Michael S. Tsirkin <mst@redhat.com>
> CC: Jason Wang <jasowang@redhat.com>
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Applied and queued up for -stable, thanks!
