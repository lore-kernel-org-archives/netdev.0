From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] TCP FIN gets dropped prematurely, results in ack storm
Date: Tue, 1 May 2007 22:07:08 +0400
Message-ID: <20070501180708.GA1882@2ka.mipt.ru>
References: <20070501151354.GB1751@kvack.org> <20070501162050.GB21896@2ka.mipt.ru> <20070501164935.GC1751@kvack.org> <46377EBB.6080604@psc.edu> <20070501180405.GE1751@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: John Heffner <jheffner@psc.edu>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:42536 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755243AbXEASHY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 14:07:24 -0400
Content-Disposition: inline
In-Reply-To: <20070501180405.GE1751@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 01, 2007 at 02:04:05PM -0400, Benjamin LaHaise (bcrl@kvack.org) wrote:
> I know it's a bug, and I'm trying to fix it, but that doesn't change the 
> fact that A) the system is already deployed and B) Linux is not retransmitting 
> the FIN, which (from Linux's point of view) remains unacknowledged by the 
> other side.  The patch might be wrong, but the goal of fixing the behaviour 
> isn't.

It does retransmit fin:

10:23:32.298477 IP (tos 0x0, ttl 255, id 39972, offset 0, flags [DF],
proto: TCP (6), length: 52) 192.168.1.1.59192 > 192.168.2.2.bgp: F,
cksum 0x5558 (correct), 1562038077:1562038077(0) ack 2624175183 win 183
<nop,nop,timestamp 1549356119 781231>
10:23:32.599809 IP (tos 0x0, ttl 255, id 39973, offset 0, flags [DF],
proto: TCP (6), length: 52) 192.168.1.1.59192 > 192.168.2.2.bgp: F,
cksum 0x542b (correct), 1562038077:1562038077(0) ack 2624175183 win 183
<nop,nop,timestamp 1549356420 781231>
10:23:33.201722 IP (tos 0x0, ttl 255, id 40802, offset 0, flags [DF],
proto: TCP (6), length: 52) 192.168.1.1.59192 > 192.168.2.2.bgp: F,
cksum 0x51d1 (correct), 1562038077:1562038077(0) ack 2624175183 win 183
<nop,nop,timestamp 1549357022 781231>
10:23:34.405537 IP (tos 0x0, ttl 255, id 40914, offset 0, flags [DF],
proto: TCP (6), length: 52) 192.168.1.1.59192 > 192.168.2.2.bgp: F,
cksum 0x4d1d (correct), 1562038077:1562038077(0) ack 2624175183 win 183
<nop,nop,timestamp 1549358226 781231>


-- 
	Evgeniy Polyakov
