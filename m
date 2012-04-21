From: Flavio Leitner <fbl@redhat.com>
Subject: restoring IP multicast addresses when restarting the interface.
Date: Fri, 20 Apr 2012 21:25:33 -0300
Message-ID: <20120420212533.78903e3a@asterix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.hengli.com.au>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62755 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751826Ab2DUA0l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2012 20:26:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello folks,

I was told that ntp in multicast mode was not working if you
restart the interface (ifdown <iface> ; ifup <iface) on an
older kernel.

It seemed obvious to me, but when I tried to reproduce this
upstream (last kernel of today), I noticed that the kernel
does restore the previous added multicast addresses. Therefore,
there is no issues.

I found that this is due to mainly this commit below which
doesn't remove idev when the addresses are deleted.

commit 6363097cc4d182f93788131b5d8f72aa91d950a0
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Thu Jun 7 18:35:38 2007 -0700

    [IPV4]: Do not remove idev when addresses are cleared
    
    Now that we create idev before addresses are added, it no longer makes
    sense to remove them when addresses are all deleted.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>


Although the new behavior seems nice and save some user space
work, I think it was unintentional and likely to be a bug.

What you guys think?

thanks,
fbl
