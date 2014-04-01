From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: cache coherency problem, why not happening ?
Date: Tue, 1 Apr 2014 11:30:35 +0200
Message-ID: <20140401093035.GE24150@order.stressinduktion.org>
References: <CAGZFCEFDM109559QWXMSoy7Cru5-2MQt-4FX_tk6uK1-u7M-7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev <netdev@vger.kernel.org>,
	Netfilter mailing list <netfilter@vger.kernel.org>
To: ratheesh kannoth <ratheesh.ksz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:43895 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324AbaDAJag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 05:30:36 -0400
Content-Disposition: inline
In-Reply-To: <CAGZFCEFDM109559QWXMSoy7Cru5-2MQt-4FX_tk6uK1-u7M-7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 01, 2014 at 09:49:53AM +0530, ratheesh kannoth wrote:
> Suppose in smp machine,  if  bottom half is executed by  cpu #1  and
> the  userspace process is pinned to cpu #2.  How can the  spin lock
> acuquired info ( lock value ) will be reflected   to cpu #2 ( if cpu
> #2 has already acquired and released the lock value and the lock value
> is  stored in a cpu #2 data cache. so if cpu #1 acquire it , cpu#2
> will read the cache value which says it is free). I could see that
> spin_lock_t is not a volatile value also.

volatile is a construct from C-language standard and does not help that much
with syncing to CPUs.

(Specific for Intel processors, now)

If you read the beginning of Chapter 8
<http://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-system-programming-manual-325384.pdf>

then lookup ticket spinlocks and then revisit the spin_lock implementation it
should get clear.

Have fun,

  Hannes
