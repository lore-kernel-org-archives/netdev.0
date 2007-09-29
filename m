From: Andrea Arcangeli <andrea@suse.de>
Subject: delayed acks question
Date: Sat, 29 Sep 2007 02:51:57 +0200
Message-ID: <20070929005156.GF10232@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:38475 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755819AbXI2AwA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 20:52:00 -0400
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 27AF9158FC
	for <netdev@vger.kernel.org>; Sat, 29 Sep 2007 02:51:59 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I've a few questions about ICSK_ACK_PUSHED2.

PUSHED2 is only meant to force the ack out immediately when pingpong
is set to 1, but then if pingpong is 1 the delayed acks shouldn't be
deferred anyway. However I think the trouble is that there's a race
condition in reading pingpong, pingpong is only valid for the receiver
tcp context, not for the userland code reading the receive buffer. By
the time userland reads the receive buffer the other context may have
changed.

Is PUSHED2 ever cleared? Is PUSHED ever cleared in the first place?

Why can't PUSHED2 be deleted together with the pingpong check, making
PUSHED enough to guarantee to send the ack out once the receive buffer
is empty.

We've seen hangs of 40msec during slow start caused by the delayed
acks that PUSHED2 seems to fix, but while reviewing it I can't see how
could it possibly make sense to have a pingpong check in the userland
side when pingpong will change all the time anytime (making
TCP_QUICKACK a funny joke too).

Thanks.

PS. I'm not subscribed to netdev, I looked into this incidentally, so
please include me in the CC.
