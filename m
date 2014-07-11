From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH for stable 3.10] xen-netback: drop SKB from internal
 queue if frontend is disconnected
Date: Fri, 11 Jul 2014 14:15:29 +0100
Message-ID: <1405084529.27875.1.camel@kazak.uk.xensource.com>
References: <1405084112-8134-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Philipp Hahn <hahn@univention.de>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:37650 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753191AbaGKNPb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2014 09:15:31 -0400
In-Reply-To: <1405084112-8134-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-07-11 at 14:08 +0100, Wei Liu wrote:
> In 88a810def7 ("xen-netback: fix refcnt unbalance for 3.10"), we moved
> the ref counting code from xenvif_disconnect to xenvif_free.

Since this was a 3.10 specific backport that explains why this is also
such?

> It can occur that frontend is disconnected while there's still SKB
> stuck in netback's rx_queue in rare case. When netback thread wakes up,
> it will try to write to an already unmapped ring, resulting in kernel
> oops.
> 
> Moving the ref counting back to xenvif_disconnect isn't an option as it
> reintroduces an old bug. Further more, writing into a dead frontend's
> ring and memory is just wrong. Dropping those SKBs seems to be a good
> strategy.
> 
> This patch fixes that corner case: introduce a flag to indicate whether
> frontend ring is mapped. If the ring is unmapped, just drop those SKBs.
> 
> This bug only manifests in 3.10 kernel. Kernel >=3.12 doesn't have it.

What about 3.11?
