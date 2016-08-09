From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] vti: flush x-netns xfrm cache when vti
 interface is removed
Date: Tue, 09 Aug 2016 12:58:31 -0700 (PDT)
Message-ID: <20160809.125831.2234397547026038583.davem@davemloft.net>
References: <1470770982-1606-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lrichard@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:32941 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932378AbcHIT6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 15:58:33 -0400
Received: by mail-pa0-f68.google.com with SMTP id vy10so1425779pac.0
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 12:58:33 -0700 (PDT)
In-Reply-To: <1470770982-1606-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lance Richardson <lrichard@redhat.com>
Date: Tue,  9 Aug 2016 15:29:42 -0400

> When executing the script included below, the netns delete operation
> hangs with the following message (repeated at 10 second intervals):
> 
>   kernel:unregister_netdevice: waiting for lo to become free. Usage count = 1
> 
> This occurs because a reference to the lo interface in the "secure" netns
> is still held by a dst entry in the xfrm bundle cache in the init netns.
> 
> Address this problem by garbage collecting the tunnel netns flow cache
> when a cross-namespace vti interface receives a NETDEV_DOWN notification.
 ...
> Reported-by: Hangbin Liu <haliu@redhat.com>
> Reported-by: Jan Tluka <jtluka@redhat.com>
> Signed-off-by: Lance Richardson <lrichard@redhat.com>
> ---
> v2: Perform garbage collection on NETDEV_DOWN notification (v1 did this 
>     in uninit op handler).

Looks good, applied and queued up for -stable, thanks!
