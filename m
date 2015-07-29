From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: mdb: fix delmdb state in the notification
Date: Wed, 29 Jul 2015 15:03:14 -0700 (PDT)
Message-ID: <20150729.150314.217450368845250422.davem@davemloft.net>
References: <1438081844-18801-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	stephen@networkplumber.org, cwang@twopensource.com,
	amwang@redhat.com, nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34430 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753451AbbG2WDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 18:03:15 -0400
In-Reply-To: <1438081844-18801-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Tue, 28 Jul 2015 13:10:44 +0200

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> Since mdb states were introduced when deleting an entry the state was
> left as it was set in the delete request from the user which leads to
> the following output when doing a monitor (for example):
> $ bridge mdb add dev br0 port eth3 grp 239.0.0.1 permanent
> (monitor) dev br0 port eth3 grp 239.0.0.1 permanent
> $ bridge mdb del dev br0 port eth3 grp 239.0.0.1 permanent
> (monitor) dev br0 port eth3 grp 239.0.0.1 temp
> ^^^
> Note the "temp" state in the delete notification which is wrong since
> the entry was permanent, the state in a delete is always reported as
> "temp" regardless of the real state of the entry.
> 
> After this patch:
> $ bridge mdb add dev br0 port eth3 grp 239.0.0.1 permanent
> (monitor) dev br0 port eth3 grp 239.0.0.1 permanent
> $ bridge mdb del dev br0 port eth3 grp 239.0.0.1 permanent
> (monitor) dev br0 port eth3 grp 239.0.0.1 permanent
> 
> There's one important note to make here that the state is actually not
> matched when doing a delete, so one can delete a permanent entry by
> stating "temp" in the end of the command, I've chosen this fix in order
> not to break user-space tools which rely on this (incorrect) behaviour.
> 
> So to give an example after this patch and using the wrong state:
> $ bridge mdb add dev br0 port eth3 grp 239.0.0.1 permanent
> (monitor) dev br0 port eth3 grp 239.0.0.1 permanent
> $ bridge mdb del dev br0 port eth3 grp 239.0.0.1 temp
> (monitor) dev br0 port eth3 grp 239.0.0.1 permanent
> 
> Note the state of the entry that got deleted is correct in the
> notification.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Fixes: ccb1c31a7a87 ("bridge: add flags to distinguish permanent mdb entires")

Applied and queued up for -stable, thanks.
