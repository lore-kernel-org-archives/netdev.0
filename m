From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/3] drivers/net/ipg.c: Fix skbuff leak
Date: Tue, 15 Jan 2008 00:15:49 +0100
Message-ID: <20080114231549.GB29734@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58350 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750921AbYANX31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 18:29:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
> From: Francois Romieu <romieu@fr.zoreil.com>
> > 
> > I should be able to test your r8169 NAPI changes tomorrow.
> 
> Thank you.

(sorry for the delay)

I think that the r8169 part should be reverted.

. With it, my 8169 oopsed unexpectedly in rtl8169_reinit_task a few
  seconds after I started a 'ping -q -f -l64 -s 36' and before I did
  anything else. I do not have a clear explanation for the oops yet.

. rtl8169_reset_task will not like it as it could allow two racing
  r8169_rx_interrupt.

. The irq will be enabled later when needed: the modified code is
  only relevant for the reset/reinit tasks.

. After reverting the hunk, the 8168 in the same box stood the same
  stream (> 50kpps in both direction). Everything worked as expected
  when I ifconfiged it down, then up again. Same thing when I pluged
  the cable out then in.

I'll give it more testing/thought.

-- 
Ueimor
