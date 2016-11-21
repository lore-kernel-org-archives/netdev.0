From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2 next 0/2] tcp: make undo_cwnd mandatory for congestion modules
Date: Mon, 21 Nov 2016 14:18:36 +0100
Message-ID: <1479734318-30607-1-git-send-email-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:38102 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754179AbcKUNSY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 08:18:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

highspeed, illinois, scalable, veno and yeah congestion control algorithms
don't provide a 'cwnd_undo' function.  This makes the stack default to a
'reno undo' which doubles cwnd.  However, the ssthresh implementation of
these algorithms do not halve the slowstart threshold. This causes similar
issue as the one fixed for dctcp in ce6dd23329b1e ("dctcp: avoid bogus
doubling of cwnd after loss").

In light of this it seems better to remove the fallback and make undo_cwnd
mandatory.

First patch fixes those spots where reno undo seems incorrect by providing
.cwnd_undo functions, second patch removes the fallback.
