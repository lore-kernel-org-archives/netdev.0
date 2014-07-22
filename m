From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/RFC] net: Don't save mid batch datagram processing
 error for next recvmmsg call
Date: Mon, 21 Jul 2014 21:17:54 -0700 (PDT)
Message-ID: <20140721.211754.1556855471792264676.davem@davemloft.net>
References: <20140721193042.GA20303@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, caitlin.bestler@gmail.com,
	chris.friesen@windriver.com, David.Laight@ACULAB.COM,
	eliedebrauwer@gmail.com, mtk.manpages@gmail.com,
	nhorman@tuxdriver.com, neleai@seznam.cz, paul@paul-moore.com,
	remi@remlab.net, steve@chygwyn.com
To: acme@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41125 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228AbaGVER6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 00:17:58 -0400
In-Reply-To: <20140721193042.GA20303@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@kernel.org>
Date: Mon, 21 Jul 2014 16:30:42 -0300

> From 5cf1a5c682c8bb0add9adfb5167a63f269136523 Mon Sep 17 00:00:00 2001
> From: Arnaldo Carvalho de Melo <acme@redhat.com>
> Date: Mon, 21 Jul 2014 12:39:56 -0300
> Subject: [PATCH 2/2] net: Don't save mid batch datagram processing error for
>  next recvmmsg call
> MIME-Version: 1.0
> Content-Type: text/plain; charset=UTF-8
> Content-Transfer-Encoding: 8bit
> 
> When the call to the underlying per protocol recvmsg fails for some
> reason and we already have successfully processed at least one datagram
> in the batch, we were saving the error for the next recvmmsg (or
> recvmsg) call, so the user would eventually get notified of what
> happened.
> 
> This was found to be fraught with problems, as, for instance, errors
> could be notified for a different thread than a faulty one providing
> invalid buffers.
> 
> So just return the number of datagrams successfully received.
> 
> Reported-by: David Laight <David.Laight@ACULAB.COM>
 ...
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

This is absolutely correct, any time we have a partial success we must
indicate success and the amount that was properly transferred, leaving
the error signalling for a subsequent retry (if any).
