From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [2.6.25-rc1] Locks in udp_recvmsg()?
Date: Mon, 11 Feb 2008 11:20:37 +0900
Message-ID: <200802111120.GFD39029.SOQLtFOMJFHFVO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:59690 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751476AbYBKCUi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Feb 2008 21:20:38 -0500
Received: from CLAMP (p2179-ipbf3301marunouchi.tokyo.ocn.ne.jp [122.29.101.179])
	by smtp.wine.ocn.ne.jp (Postfix) with ESMTP id F02773523
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 11:20:36 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

I found that udp_recvmsg() in net/ipv4/udp.c for 2.6.25-rc1 calls
lock_sock() only when it releases the datagram (i.e. out_free: and csum_copy_err:).
Is it correct to call __skb_recv_datagram() without calling lock_sock()
when it acquires the datagram (i.e. try_again:)?

Regards.
