From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Question with secure_ipv4_port_ephemeral() implementation
Date: Fri, 20 Apr 2012 21:30:29 +0900
Message-ID: <201204202130.IJF95312.tQJFLMFOFSVHOO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:50512 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752371Ab2DTMae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 08:30:34 -0400
Received: from www262.sakura.ne.jp (ksav52.sakura.ne.jp [219.94.192.132])
	by www262.sakura.ne.jp (8.14.3/8.14.3) with ESMTP id q3KCUWoo053899
	for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 21:30:32 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from CLAMP (KD175108057186.ppp-bb.dion.ne.jp [175.108.57.186])
	by www262.sakura.ne.jp (8.14.3/8.14.3) with ESMTP id q3KCUVRW053882
	for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 21:30:31 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 6e5714ea "net: Compute protocol sequence numbers and fragment IDs using
MD5." removed periodic get_random_bytes() calls. After that commit,

  static u32 net_secret[MD5_MESSAGE_BYTES / 4] ____cacheline_aligned;

is filled with random bytes for only once upon boot and is never updated again.
Then, shouldn't net_secret be marked as __read_mostly?

Just from curiosity... what was the reason for changing
secure_ipv4_port_ephemeral() generate same return value for same arguments?
Was periodically changing return value for same arguments unfriendly with NAT
or something?
