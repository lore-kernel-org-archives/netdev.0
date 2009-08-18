From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: mlx4 2.6.31-rc5: SW2HW_EQ failed.
Date: Tue, 18 Aug 2009 11:50:00 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908181148460.3840@gentwo.org>
References: <alpine.DEB.1.10.0908171523330.20399@gentwo.org> <ada7hx22j3g.fsf@cisco.com> <alpine.DEB.1.10.0908171814210.15956@gentwo.org> <ada3a7p3o6f.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:51510 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752543AbZHRPuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 11:50:05 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 749B282C73A
	for <netdev@vger.kernel.org>; Tue, 18 Aug 2009 11:50:15 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 1-gzCCJFjjGE for <netdev@vger.kernel.org>;
	Tue, 18 Aug 2009 11:50:10 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id CB59982C68A
	for <netdev@vger.kernel.org>; Tue, 18 Aug 2009 11:50:10 -0400 (EDT)
In-Reply-To: <ada3a7p3o6f.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Aug 2009, Roland Dreier wrote:

>  > Device FW??? The log you wanted follows at the end of this message.
>
> Not sure why there are "???" there... the (-5) error code is an
> "internal error" status from the device FW on the event queue
> initialization command.  Anyway I think the log shows that the problem
> is exactly the one fixed in the commit I mentioned -- a423b8a0
> ("mlx4_core: Allocate and map sufficient ICM memory for EQ context")
> from my infiniband.git tree should fix this.

Never heard of device FW.
>
> The log
>
>  > [ 7425.199430] mlx4_core 0000:04:00.0: irq 70 for MSI/MSI-X
> ...
>  > [ 7425.199488] mlx4_core 0000:04:00.0: irq 102 for MSI/MSI-X
>
> shows 33 event queues being allocated (num_possible_cpus() + 1) and that
> will hit the issue fixed in that commit.
>
> Assuming this fixes it for you, I guess I should get this into 2.6.31,
> since it obviously is hitting not-particularly-exotic systems in
> practice.  I do wonder why num_possible_cpus() is 32 on your box (since
> 16 threads is really the max with nehalem EP).

The Mellanox NIC has two ports. Could that be it?

> commit a423b8a022d523abe834cefe67bfaf42424150a7

Will get back to you shortly when we have tested this patch.

