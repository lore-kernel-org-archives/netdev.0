From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] unix: correctly track in-flight fds in sending
 process user_struct
Date: Mon, 08 Feb 2016 10:32:27 -0500 (EST)
Message-ID: <20160208.103227.1734389685709628459.davem@davemloft.net>
References: <1454461863-20844-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dh.herrmann@gmail.com, w@1wt.eu,
	torvalds@linux-foundation.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46249 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014AbcBHPce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 10:32:34 -0500
In-Reply-To: <1454461863-20844-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed,  3 Feb 2016 02:11:03 +0100

> The commit referenced in the Fixes tag incorrectly accounted the number
> of in-flight fds over a unix domain socket to the original opener
> of the file-descriptor. This allows another process to arbitrary
> deplete the original file-openers resource limit for the maximum of
> open files. Instead the sending processes and its struct cred should
> be credited.
> 
> To do so, we add a reference counted struct user_struct pointer to the
> scm_fp_list and use it to account for the number of inflight unix fds.
> 
> Fixes: 712f4aad406bb1 ("unix: properly account for FDs passed over unix sockets")
> Reported-by: David Herrmann <dh.herrmann@gmail.com>
> Cc: David Herrmann <dh.herrmann@gmail.com>
> Cc: Willy Tarreau <w@1wt.eu>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks Hannes.
