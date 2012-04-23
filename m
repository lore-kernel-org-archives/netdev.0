From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive
 for TCP
Date: Mon, 23 Apr 2012 23:30:31 +0200
Message-ID: <1335216631.5205.71.camel@edumazet-glaptop>
References: <1335173934.3293.84.camel@edumazet-glaptop>
	 <4F958DFD.7010207@hp.com> <1335201795.5205.35.camel@edumazet-glaptop>
	 <20120423.160149.1515408777176168288.davem@davemloft.net>
	 <1335213446.5205.65.camel@edumazet-glaptop>  <4F95C22D.3010908@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com, ncardwell@google.com, maze@google.com,
	ycheng@google.com, ilpo.jarvinen@helsinki.fi
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:41849 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755731Ab2DWVag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 17:30:36 -0400
Received: by wibhj6 with SMTP id hj6so3261258wib.1
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2012 14:30:35 -0700 (PDT)
In-Reply-To: <4F95C22D.3010908@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-23 at 13:57 -0700, Rick Jones wrote:
> On 04/23/2012 01:37 PM, Eric Dumazet wrote:
> > In my 10Gbit tests (standard netperf using 16K buffers), I've seen
> > backlogs of 300 ACK packets...
> 
> Probably better to call that something other than 16K buffers - the send 
> size was probably 16K, which reflected SO_SNDBUF at the time the data 
> socket was created, but clearly SO_SNDBUF grew in that timeframe.
> 


Maybe I was not clear : Application does sendmsg() of 16KB buffers.

Yet, in the small time it takes to perform this operation, softirq can
queue up to 300 packets coming from the other side.
