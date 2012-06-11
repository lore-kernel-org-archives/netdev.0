From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_packet: check loop for greater than zero in
 tpacket_fill_skb
Date: Sun, 10 Jun 2012 20:10:15 -0700 (PDT)
Message-ID: <20120610.201015.1131273088392536549.davem@davemloft.net>
References: <4FD4F494.6020102@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: danborkmann@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39404 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752807Ab2FKDKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jun 2012 23:10:16 -0400
In-Reply-To: <4FD4F494.6020102@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <danborkmann@iogearbox.net>
Date: Sun, 10 Jun 2012 21:25:08 +0200

> It could be more safe to check the 'to_write' for 'greater than zero'
> instead for 'not zero'. 'to_write' is of type int and subtraction operations
> are performed on it, so in the case of malformed values that are
> subtracted from 'to_write', it could become less than zero, which is then
> interpreted as 'not zero' in the while condition, thus the loop won't
> return as expected.
> 
> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>

I hate this kind of change.

The implication is that there are bugs in the loop that can cause
the value to go negative.

Unless you can show that this actually happens, leave this clean
test alone.
