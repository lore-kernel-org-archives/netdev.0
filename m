From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bnx2x: fix DMA unmapping of TSO split BDs
Date: Thu, 09 Jan 2014 09:52:03 -0800
Message-ID: <1389289923.31367.39.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389274587-6097-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel Elior <ariele@broadcom.com>,
	Yuval Mintz <yuvalmin@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	David Miller <davem@davemloft.net>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:37417 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756070AbaAIRwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 12:52:08 -0500
Received: by mail-gg0-f174.google.com with SMTP id g10so148992gga.19
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 09:52:05 -0800 (PST)
In-Reply-To: <1389274587-6097-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-09 at 14:36 +0100, Michal Schmidt wrote:
> bnx2x triggers warnings with CONFIG_DMA_API_DEBUG=y:
> 
>   WARNING: CPU: 0 PID: 2253 at lib/dma-debug.c:887 check_unmap+0xf8/0x920()
>   bnx2x 0000:28:00.0: DMA-API: device driver frees DMA memory with
>   different size [device address=0x00000000da2b389e] [map size=1490 bytes]
>   [unmap size=66 bytes]
> 
> The reason is that bnx2x splits a TSO BD into two BDs (headers + data)
> using one DMA mapping for both, but it uses only the length of the first
> BD when unmapping.
> 
> This patch fixes the bug by unmapping the whole length of the two BDs.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> ---

Reviewed-by: Eric Dumazet <edumazet@google.com>
