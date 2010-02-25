From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] bnx2x: fix tx queue locking and memory barriers
Date: Thu, 25 Feb 2010 08:06:24 -0800 (PST)
Message-ID: <20100225.080624.203625652.davem@davemloft.net>
References: <20100225164015.3991ab5e@dhcp-lab-109.englab.brq.redhat.com>
	<8628FE4E7912BF47A96AE7DD7BAC0AADCB46A2ADC5@SJEXCHCCR02.corp.ad.broadcom.com>
	<20100225170308.6294aa1a@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladz@broadcom.com, netdev@vger.kernel.org, eilong@broadcom.com,
	dhowells@redhat.com
To: sgruszka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48338
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932559Ab0BYQGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 11:06:09 -0500
In-Reply-To: <20100225170308.6294aa1a@dhcp-lab-109.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stanislaw Gruszka <sgruszka@redhat.com>
Date: Thu, 25 Feb 2010 17:03:08 +0100

> On Thu, 25 Feb 2010 07:49:48 -0800
> "Vladislav Zolotarov" <vladz@broadcom.com> wrote:
> 
>> In bnx2x_start_xmit(): right after the "stop queue" there is an smp_mb(), which will bring the cpu0 cache and a fresh fp->tx_bd_cons value to cpu1 and the following if() will return true and the queue will be released from bnx2x_start_xmit() flow.
> 
> If I understand correctly what is written in Documentation/memory-barriers.txt
> this smp_mb() need to have another "paired" smp_{w}mb() on cpu0 to make value
> be updated on cpu1, which is missing.

The invocation of ->hard_start_xmit() creates an implicit memory
barrier because all such invocations take the netdev spinlock.
