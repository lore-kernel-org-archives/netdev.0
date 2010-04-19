From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 10/13] bnx2x: Set default value of num_queues to 1
 on 32-bit platforms
Date: Mon, 19 Apr 2010 09:06:21 +0300
Message-ID: <1271657181.27125.20.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1271602224.27235.199.camel@lb-tlvb-vladz>
 <20100418.211023.104052199.davem@davemloft.net>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Vladislav Zolotarov" <vladz@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4260 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751562Ab0DSGGf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Apr 2010 02:06:35 -0400
In-Reply-To: <20100418.211023.104052199.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-04-18 at 21:10 -0700, David Miller wrote:
> From: "Vladislav Zolotarov" <vladz@broadcom.com>
> Date: Sun, 18 Apr 2010 17:50:24 +0300
> 
> > The default was changed to save memory on 32bits systems.
> > 
> > Author: Dmitry Kravkov <dmitry@broadcom.com>
> > Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> > Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> 
> This is absolutely rediculious.
> 
> There is no reason in the world to restrict multiqueue to only 64-bit
> systems.
> 
> If there is a memory allocation issue, fix that!  Is it vmalloc() space
> usage?

Yes - running low on vmalloc is the reason. This patch does not restrict
the usage of multi queue on 32bits - it is just changing the default
queues values from the number of available CPUs to 1. If the user will
use another value, it will work as before.

We encounter few issues were a 32bit kernel was installed on a
multi-core platform and the driver allocated "too many" queues. One way
to go is to limit the queue size and the other is the number of queues -
leaving it as is caused issues due to running low on kernel virtual
memory so a change was needed.

Dave, what is your preference:
- re-submitting this patch with a proper description?
- limit the size of each queue?
- other?

Thanks,
Eilon


