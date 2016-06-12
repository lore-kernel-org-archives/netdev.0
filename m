From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: alx: Work around the DMA RX overflow issue
Date: Sun, 12 Jun 2016 09:26:07 -0700
Message-ID: <1465748767.7945.77.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465724197-26253-1-git-send-email-feng.tang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org
To: Feng Tang <feng.tang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35263 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203AbcFLQ0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 12:26:11 -0400
Received: by mail-io0-f196.google.com with SMTP id n127so14194162iof.2
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 09:26:11 -0700 (PDT)
In-Reply-To: <1465724197-26253-1-git-send-email-feng.tang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-06-12 at 17:36 +0800, Feng Tang wrote:
> Commit 26c5f03 uses a new skb allocator to avoid the RFD overflow
> issue.
> 
> But from debugging without datasheet, we found the error always
> happen when the DMA RX address is set to 0x....fc0, which is very
> likely to be a HW/silicon problem.
> 
> So one idea is instead of adding a new allocator, why not just
> hitting the right target by avaiding the error-prone DMA address?
> 
> This patch will actually
> * Remove the commit 26c5f03
> * Apply rx skb with 64 bytes longer space, and if the allocated skb
>   has a 0x...fc0 address, it will use skb_resever(skb, 64) to
>   advance the address, so that the RX overflow can be avoided.
> 
> In theory this method should also apply to atl1c driver, which
> I can't find anyone who can help to test on real devices.
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=70761
> Signed-off-by: Feng Tang <feng.tang@intel.com>
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Ole Lukoie <olelukoie@mail.ru>
> ---
>  drivers/net/ethernet/atheros/alx/alx.h  |  4 ---
>  drivers/net/ethernet/atheros/alx/main.c | 61 ++++++++-------------------------
>  2 files changed, 14 insertions(+), 51 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
