From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [BISECTED][REGRESSION] Loading Hyper-V network drivers is racy
 in 3.14+ on Hyper-V 2012 R2
Date: Mon, 14 Jul 2014 22:39:48 +0000
Message-ID: <8b68f48141a045f784c10f9c081cd51f@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <20140706201800.GA10587@sucs.org>
 <941b0055b1a94c66b3a608ae67764d11@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140707181341.GA2646@sucs.org> <20140711055259.GA10317@sucs.org>
 <52afbe119b1a481aa1c80f909c3a2432@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140714213032.GA23639@sucs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: KY Srinivasan <kys@microsoft.com>,
	"David S. Miller" <davem@davemloft.net>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sitsofe Wheeler <sitsofe@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na01-sn2-obe.ptr.o365filtering.com ([157.55.158.26]:39124 "EHLO
	na01-sn2-obe.outbound.o365filtering.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756749AbaGNWkW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2014 18:40:22 -0400
In-Reply-To: <20140714213032.GA23639@sucs.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Sitsofe Wheeler [mailto:sitsofe@gmail.com]
> Sent: Monday, July 14, 2014 5:31 PM
> To: Haiyang Zhang
> Cc: KY Srinivasan; David S. Miller; devel@linuxdriverproject.org; linux-
> kernel@vger.kernel.org; netdev@vger.kernel.org
> Subject: Re: [BISECTED][REGRESSION] Loading Hyper-V network drivers is
> racy in 3.14+ on Hyper-V 2012 R2
> 
> On Fri, Jul 11, 2014 at 03:25:11PM +0000, Haiyang Zhang wrote:
> > Since you found the commit b679ef73edc is related to this problem,
> > could you do a simple test:
> >   Reduce the receive buffer size back to 2MB, like below, then re-test
> >   it, see if the problem goes away?
> > 	drivers/net/hyperv/hyperv_net.h
> > 	#define NETVSC_RECEIVE_BUFFER_SIZE		(1024*1024*2)	/* 2MB
> */
> 
> After doing this I was able to reach over 900 reboots where the network
> connected properly.

Thanks for the tests! I will make a patch that can automatically retry
smaller memory allocs when memory is insufficient.

Thanks,
- Haiyang
