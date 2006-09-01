From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: high latency with TCP connections
Date: Fri, 1 Sep 2006 15:00:38 +0400
Message-ID: <20060901110038.GA3651@2ka.mipt.ru>
References: <20060831151456.12a4e080@dxpl.pdx.osdl.net> <20060831.154428.35684218.davem@davemloft.net> <20060831232923.GA10036@ms2.inr.ac.ru> <20060831.165701.104033558.davem@davemloft.net> <20060901094715.GB13855@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, shemminger@osdl.org,
	alex@sectorb.msk.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:44777 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751094AbWIALBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 07:01:34 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20060901094715.GB13855@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 01, 2006 at 01:47:15PM +0400, Alexey Kuznetsov (kuznet@ms2.inr.ac.ru) wrote:
> Hello!
> 
> > problem.  The problem is really at the receiver because we only
> > ACK every other full sized frame.  I had the idea to ACK every 2
> > frames, regardless of size,
> 
> This would solve lots of problems.

At least for slow start it is safe, but experiments with atcp for
netchannels showed that it is better not to send excessive number of
acks when slow start is over, instead we can introduce some tricky
ack avoidance scheme and ack at least 2-3-4 packets or full MSS instead
of two mss-sized frames.

> Alexey

-- 
	Evgeniy Polyakov
