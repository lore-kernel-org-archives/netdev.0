From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] net/hyperv: fix erroneous NETDEV_TX_BUSY use
Date: Wed, 14 Mar 2012 13:14:32 -0700
Message-ID: <1331756072.6022.57.camel@edumazet-glaptop>
References: <1331751214.6022.47.camel@edumazet-glaptop>
	 <4F60E9F7.4000402@candelatech.com>
	 <1331752632.6022.49.camel@edumazet-glaptop>
	 <A1F3067C9B68744AA19F6802BAB8FFDC0DCE702F@TK5EX14MBXC223.redmond.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:56060 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030518Ab2CNUOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 16:14:35 -0400
Received: by dadp12 with SMTP id p12so3452860dad.11
        for <netdev@vger.kernel.org>; Wed, 14 Mar 2012 13:14:34 -0700 (PDT)
In-Reply-To: <A1F3067C9B68744AA19F6802BAB8FFDC0DCE702F@TK5EX14MBXC223.redmond.corp.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-03-14 at 20:00 +0000, Haiyang Zhang wrote:

> Actually, I'm working on this bug, and have a patch under our internal 
> review now. My fix is actually not freeing the SKB, and return NETDEV_TX_BUSY.
> 
> Even if the vmbus ring buffer is busy currently, it can be available during
> the next re-try, because the host is taking away data from ring buffer. The 
> stop/wake queue mechanism is in the netvsc.c file.
> 
> In the out-of-memory case, dropping packet and return NETDEV_TX_OK seems fine.

That will be fine for net-next.

I sent a patch for current kernels, where obvious and minimal fixes
apply.
