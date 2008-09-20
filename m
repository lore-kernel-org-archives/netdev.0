From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCHv2 net-next 00/15]: TCP rexmit changes
Date: Sun, 21 Sep 2008 00:47:43 +0300
Message-ID: <1221947278-16715-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45382 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536AbYITVsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 17:48:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Heffner noted ages ago that TCP does O(n^2) processing
during recovery. SACKtag part was solved earlier, making
duplicate ACKs to avoid scanning the write queue unnecessarily.
This change is intented to (mostly) solve the periods when
cumulative ACKs occur during a recovery, ie., basically when
the situation starts to resolve.

v2 fixes !tp->lost_out detection in case we went already more
than 2^31 from the previous retransmit_high.

I played again with it a bit, this time I also went to see the
counters using systemtap and afaict the counters matched what
I expected to see (fwd-rexmits and some other cases related to
collapse/fragment weren't covered by my simple transfer).

--
 i.


