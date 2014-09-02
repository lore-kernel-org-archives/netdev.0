From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 2/2] sunvnet: Re-check for a VIO_DESC_READY data
 descriptor after short udelay()
Date: Tue, 02 Sep 2014 06:27:54 -0400
Message-ID: <54059BAA.1080307@oracle.com>
References: <20140829201809.GH14753@oracle.com> <20140901.204715.2121922580015092507.davem@davemloft.net>
Reply-To: sowmini.varadhan@oracle.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:45805 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752355AbaIBK16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 06:27:58 -0400
In-Reply-To: <20140901.204715.2121922580015092507.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2014 11:47 PM, David Miller wrote:

>
> If there were no more packets coming, this is wasted useless polling
> time in atomic context.

turns out that this gives a 20-30% perf improvement for tests like
iperf.

when there are no more packets coming, the extra 12 microsecond
delay is not that big of a deal anyway. The point was that the extra
12 micro-second tax in the quiescent network state is less expensive
than exiting interrupt context, taking another interrupt and doing
another ldc_read, when there is actually a burst of packets.

notice that there are many other such udelay() loops elsewhere in
the code.

I can remove the retries and submit patch 1/1 again later today.

>
> Everything should be event based, and we should not be compensating
> and making sacrifices for a producer slower than we are as a consumer.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
