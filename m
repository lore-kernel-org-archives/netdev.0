From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP regression with packets rates < 10k per sec
Date: Thu, 10 Sep 2009 17:39:17 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909101737050.27669@V090114053VZO-1>
References: <alpine.DEB.1.10.0909081820030.7733@V090114053VZO-1> <4AA6E039.4000907@gmail.com> <alpine.DEB.1.10.0909091000200.28070@V090114053VZO-1> <4AA7C512.6040100@gmail.com> <alpine.DEB.1.10.0909091234360.15538@V090114053VZO-1> <4AA7E082.90807@gmail.com>
 <alpine.DEB.1.10.0909091350590.32067@V090114053VZO-1> <4AA963A4.5080509@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:38836 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753110AbZIJVkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 17:40:33 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id ECE0982C47B
	for <netdev@vger.kernel.org>; Thu, 10 Sep 2009 17:41:39 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id NY0OeJcePevK for <netdev@vger.kernel.org>;
	Thu, 10 Sep 2009 17:41:35 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4D85982C480
	for <netdev@vger.kernel.org>; Thu, 10 Sep 2009 17:41:35 -0400 (EDT)
In-Reply-To: <4AA963A4.5080509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Sep 2009, Eric Dumazet wrote:

> 22:28:11.223581 IP 55.225.18.7.9002 > 55.225.18.5.9002: UDP, length 32
> 22:28:11.223678 IP 55.225.18.5.9002 > 55.225.18.7.9002: UDP, length 32
>
> See how the answer is *very* slow ? Something like > 100 us ?

If you run tcpdump then you create some overhead I guess. 100 usec should
show up as latencies > 50usec in the report.

The latency request includes the timestamp from the source. So the
destination can take another timestamp at receive time. The sending back
of the reply to the timestamp request is not critical at all. The receiver
will just register the time differential established by the sender.

