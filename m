From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 2/2] tun: don't set a default qdisc
Date: Wed, 13 Apr 2016 11:22:02 -0400 (EDT)
Message-ID: <20160413.112202.341079594713169936.davem@davemloft.net>
References: <cover.1460393493.git.pabeni@redhat.com>
	<1a216fb6cade7dcd7d2c1d4ce113a1ee6e3fdeb6.1460393493.git.pabeni@redhat.com>
	<20160413132411-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pabeni@redhat.com, netdev@vger.kernel.org,
	hannes@stressinduktion.org, ebiederm@xmission.com,
	gkurz@linux.vnet.ibm.com, jasowang@redhat.com
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56419 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbcDMPWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 11:22:04 -0400
In-Reply-To: <20160413132411-mutt-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Wed, 13 Apr 2016 13:26:51 +0300

> On Wed, Apr 13, 2016 at 11:04:47AM +0200, Paolo Abeni wrote:
>> This patch disables the default qdisc by explicitly setting the
>> IFF_NO_QUEUE private flag so that now the tun xmit path do not
>> require any lock by default.
>> 
>> The default qdisc was first removed as a side effect of commit
>> f84bb1eac027 ("net: fix IFF_NO_QUEUE for drivers using alloc_netdev")
>> and recently restored with commit 016adb7260f4 ("tuntap: restore default qdisc")
>> 
>> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> 
> I wonder about this back and forth.
> Jason, do you see a workload where the default qdisc
> is preferable?

I don't think you should change this, putting the default back was a
bug fix.

I think this series is taking way too many liberties in order to
achieve locklessness, in my opinion.

If you have proper multi-queue, the qdisc lock and the netdev transmit
lock are almost completely free.
