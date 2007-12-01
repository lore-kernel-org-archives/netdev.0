From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH net-2.6.25 0/21]: TCP tweaks & RB-tree WIP preview
Date: Sun,  2 Dec 2007 00:47:55 +0200
Message-ID: <11965492963603-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46714 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717AbXLAWsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 17:48:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

First, there are some rather trivial ones (up to [TCP]: Cleanup
local variables of clean _rtx_queue)...

They're followed by my current efforts to improve SACK processing
latencies with large windows, including RB-tree for fast
searching, problem space split to provide tight bounds that
relate to the amount of new information discovered through the
received SACK block, per skb fack_count to provide access to
fack_count at search provided entry point. There's still need
for additional changes after these to really provide such good
bounds without loop-holes but this is a big step in the right
direction already.

Cost to store all this, seems tremendous, however, the new
structures enable also dropping of many existing caches, making
the end result much nicer (these are not yet done). Potential
kill list includes at least: most _hints drop, recv_sack_cache
drop, highest_sack skb->seqno restore... Also the linked-list
for SACKed part is probably unnecessary but having it makes
things simpler, it can be killed later on rather than adding
complexity to this patch.

...I would like to still take some time to make the last patch
cleaner by extracting at least the DSACK separation from it.
Though, the amount of necessary changes remains still relatively
huge in the core patch. ...Minor FIXMEs todo, only the DSACK one
is really preventive one.

Comments welcome, especially about the last patch.

--
 i.



