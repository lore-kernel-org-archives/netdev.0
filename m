From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH next] be2net: add support for ndo_busy_poll
Date: Wed, 23 Oct 2013 23:13:58 -0700
Message-ID: <1382595238.7572.38.camel@edumazet-glaptop.roam.corp.google.com>
References: <1382593638-8079-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:56103 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115Ab3JXGOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 02:14:03 -0400
Received: by mail-ee0-f54.google.com with SMTP id t10so620976eei.41
        for <netdev@vger.kernel.org>; Wed, 23 Oct 2013 23:14:01 -0700 (PDT)
In-Reply-To: <1382593638-8079-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-24 at 11:17 +0530, Sathya Perla wrote:
> Includes:
> - ndo_busy_poll implementation
> - Locking between napi and busy_poll
> - Fix rx_post_starvation (replenish rx-queues in out-of-mememory scenario)
>   logic to accomodate busy_poll.

>  	if (work_done) {
> +		gfp_t gfp = (polling == BUSY_POLLING) ? GFP_KERNEL : GFP_ATOMIC;
> +
>  		be_cq_notify(adapter, rx_cq->id, true, work_done);
>  

I do not think its right.

ndo_busy_poll() is not allowed to sleep.
