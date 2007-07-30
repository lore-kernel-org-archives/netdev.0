From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6 0/2] [TCP]: Fix bidirectional brokeness
Date: Mon, 30 Jul 2007 20:16:54 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0707301947210.8788@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46773 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760090AbXG3RQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 13:16:57 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

While testing frto with bidirection TCP a while (months) ago, I 
encountered time-seq graphs which made absolutely no sense as if 
recoveries only completed after RTO. As a result, I noticed that 
rate-halving has problem when a flow is bidirection but testing the
patch has been on my todo list for ages.  ...Finally, here it is...
...Please think the first one a bit because there might be some
corner cases with reno.

While testing it I came across with an additional issue that can
occur with bidirectional traffic. And, even better, the second fix
seems to also solves a third issue which affects both unidirectional
and bidirectional flows, though it's a marginal case (cumulative
ACK that causes a larger number of new SACKed skbs). I've never
seen that third one to occur but it's there if you get enough ACK
losses, subsequent ACKs (if one gets them) do solve it so that's
not a very bad issue to begin with...

I've verified these from time-seq graphs on top of tcp-2.6, which
had some additional (mostly cleanup and the rebase I promised you
earlier) though I added the tp->fackets_out > tp->reordering check
afterwards as it seems necessary to avoid going to lost marker too
often (wouldn't have had any effect in my test case anyway).

...Please consider to net-2.6 and to stable too.

These will generate you some hassle when you rebase tcp-2.6. Btw, you 
forgot to push tcp-2.6 out last time though I could assume it's
state... :-) In case you're going to now push it out, could you please
drop "[TCP]: Remove num_acked>0 checks from cong.ctrl mods pkts_acked"
from it as it seems to be out of place in tcp-2.6, I can resubmit it
to net-2.6.24 when you open it (unless you want to put it to net-2.6 
directly as it's rather trivial one).


-- 
 i.
