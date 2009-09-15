From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP regression with packets rates < 10k per sec
Date: Tue, 15 Sep 2009 10:07:01 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909151000230.20318@V090114053VZO-1>
References: <alpine.DEB.1.10.0909081820030.7733@V090114053VZO-1> <4AA6E039.4000907@gmail.com> <alpine.DEB.1.10.0909091000200.28070@V090114053VZO-1> <4AA7C512.6040100@gmail.com> <alpine.DEB.1.10.0909091234360.15538@V090114053VZO-1> <4AA7E082.90807@gmail.com>
 <alpine.DEB.1.10.0909091350590.32067@V090114053VZO-1> <4AA963A4.5080509@gmail.com> <4AA97183.3030008@gmail.com> <alpine.DEB.1.10.0909101741520.9964@V090114053VZO-1> <alpine.DEB.1.10.0909141708150.8051@V090114053VZO-1> <4AAF263E.9010405@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:44292 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751511AbZIOOJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 10:09:07 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 04EF682C776
	for <netdev@vger.kernel.org>; Tue, 15 Sep 2009 10:10:42 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id qZJcRM+qBwfE for <netdev@vger.kernel.org>;
	Tue, 15 Sep 2009 10:10:37 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5803982C6D5
	for <netdev@vger.kernel.org>; Tue, 15 Sep 2009 10:10:37 -0400 (EDT)
In-Reply-To: <4AAF263E.9010405@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Sep 2009, Eric Dumazet wrote:

> 2.6.31 is actually faster than 2.6.22 on the bench you provided.

Well at high packet rates which were not the topic.

> Must be specific to the hardware I guess ?

Huh? Even your loopback numbers did show the regression up to 10k.

> As text size presumably is bigger in 2.6.31, fetching code
> in cpu caches to handle 10 packets per second is what we call
> a cold path anyway.

Ok so its an accepted regression? This is a significant reason not to use
newer versions of kernels for latency critical applications that may have
to send a packet once in a while for notification. The latency is doubled
(1G) / tripled / quadrupled (IB) vs 2.6.22.

> If you want to make it a fast path, you want to make sure code its
> always hot in cpu caches, and find a way to inject packets into
> the kernel to make sure cpu keep the path hot.

Oh, gosh.


