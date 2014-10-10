From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Subject: Re: [PATCH net-next 0/2] sunvnet: Packet processing in non-interrupt context.
Date: Thu, 9 Oct 2014 18:10:24 -0700
Message-ID: <EB9A1CD1-6E1D-409C-89CB-95CC9A5AFC1D@oracle.com>
References: <20141003144024.GA12448@oracle.com> <20141003.120802.1213573830649867131.davem@davemloft.net> <20141006160418.GA3604@oracle.com> <20141006.152526.965519223260573233.davem@davemloft.net> <20141006193111.GE24721@oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:43194 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbaJJBK3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 21:10:29 -0400
In-Reply-To: <20141006193111.GE24721@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I would like to share my experience, on sparc we need more parallelism to
get the high performance that's just the nature of CMT processors(at least today).
Lock less Tx and Rx implementation is very nice, but requires to the code path to
single threaded to achieve it. This may limit the performance to the single thread
performance, that may be not very high for standard MTU packets. The large MTU packets
like 64K MTU may have some advantage due to less processing both in the stack
and the driver, but still  single thread would limit the max performance. I would suggest
explore both lock less and high parallelism methods to see which one gives the
best performance.

-Raghuram
On Oct 6, 2014, at 12:31 PM, Sowmini Varadhan <sowmini.varadhan@oracle.com> wrote:

> On (10/06/14 15:25), David Miller wrote:
>> 
>>> But we still need to hold the vio lock around the ldc_write 
>>> (and also around dring write) in vnet_start_xmit, right?
>> 
>> You might be able to avoid it, you're fully serialized by the TX queue
>> lock.
> 
> yes, I was just noticing that. The only place where I believe I need
> to hold the vio spin-lock is to sync with the dr->cons checks
> (the "should I send a start_cons LDC message?" check in vnet_start_xmit()
> vs the vnet_ack() updates).
> 
> But isn't it better in general to declare NETIF_F_LLTX and have finer lock
> granularity in the driver?
> 
> --Sowmini
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
