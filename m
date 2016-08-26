From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v1 1/1 net-next] 8139cp: Fix one possible deadloop in
 cp_rx_poll
Date: Thu, 25 Aug 2016 17:02:59 -0700 (PDT)
Message-ID: <20160825.170259.1411639595965936537.davem@redhat.com>
References: <1472089539-11543-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@48lvckh6395k16k5.yundunddos.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44044 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751799AbcHZA0y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 20:26:54 -0400
In-Reply-To: <1472089539-11543-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Thu, 25 Aug 2016 09:45:39 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> When cp_rx_poll does not get enough packet, it will check the rx
> interrupt status again. If so, it will jumpt to rx_status_loop again.
> But the goto jump resets the rx variable as zero too.
> 
> As a result, it causes one possible deadloop. Assume this case,
> rx_status_loop only gets the packet count which is less than budget,
> and (cpr16(IntrStatus) & cp_rx_intr_mask) condition is always true.
> It causes the deadloop happens and system is blocked.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Makes sense, applied, thanks.
