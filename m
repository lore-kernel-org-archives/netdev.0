From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP regression with packets rates < 10k per sec
Date: Wed, 9 Sep 2009 13:26:22 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909091323570.32067@V090114053VZO-1>
References: <alpine.DEB.1.10.0909081820030.7733@V090114053VZO-1> <4AA6E039.4000907@gmail.com> <alpine.DEB.1.10.0909091000200.28070@V090114053VZO-1> <4AA7C512.6040100@gmail.com> <alpine.DEB.1.10.0909091234360.15538@V090114053VZO-1>
 <4AA7E0FA.5070005@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:42940 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752923AbZIIR10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 13:27:26 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D2E9782C16B
	for <netdev@vger.kernel.org>; Wed,  9 Sep 2009 13:28:25 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id yU7zPcPpPH+t for <netdev@vger.kernel.org>;
	Wed,  9 Sep 2009 13:28:21 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6F0DC82C290
	for <netdev@vger.kernel.org>; Wed,  9 Sep 2009 13:28:20 -0400 (EDT)
In-Reply-To: <4AA7E0FA.5070005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Sep 2009, Eric Dumazet wrote:

> I have no idea how you run the test then, and how are computed time deltas.
>
> Are you clocks synchronized to less than one us ? How is it done ?

Packets are sent one way and include a timestamp. Once in a while (probe
interval) a packet is sent back to the sender (with the timestamp the
sender took earlier). The sender takes a second timestamp and
calculates the latency by dividing by two.

Seen this approach in multiple middleware test programs. Clocks are
typically not synchronized enough to actually compare timestamps from two
systems.

