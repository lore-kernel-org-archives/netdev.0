From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2 1/1] alx: add a simple AR816x/AR817x device driver
Date: Wed, 12 Jun 2013 20:02:15 +0200
Message-ID: <1371060135.8601.32.camel@jlt4.sipsolutions.net>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
	 <1370899746-14219-1-git-send-email-johannes@sipsolutions.net>
	 <20130611222313.GA25499@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcgrof@do-not-panic.com, kvalo@adurom.com,
	adrian.chadd@gmail.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:42796 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757697Ab3FLSCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 14:02:19 -0400
In-Reply-To: <20130611222313.GA25499@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-12 at 00:23 +0200, Francois Romieu wrote:

Thanks for looking!

> - The bitops for alx->int_mask in alx_check_link and alx_poll race.
>   ALX_ISR_{TX/RX}_Q0 may end disabled if alx_check_link wins.

Ahrg, yes, I saw this before but forgot, sorry :-(

> - dev_alloc_skb is a bit legacy. You may netdev_alloc_skb (_ip_align ?).

Hmm, ok? This was new to me, I'll check it out as well as alignment.

> - no spin_lock_init ?

Ouch.

> - budget may not be honored in alx_clean_rx_irq

Hmm, I'll take another look. I thought only the TX part wasn't doing
this properly, but this was my first foray into real NAPI usage so I'm
not surprised I got it wrong :-)

johannes
