From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [RFC PATCH] bnx2x: fix tx queue locking and memory barriers
Date: Thu, 25 Feb 2010 17:03:08 +0100
Message-ID: <20100225170308.6294aa1a@dhcp-lab-109.englab.brq.redhat.com>
References: <20100225140834.0169e9f2@dhcp-lab-109.englab.brq.redhat.com>
	<20100225.021822.66777947.davem@davemloft.net>
	<20100225164015.3991ab5e@dhcp-lab-109.englab.brq.redhat.com>
	<8628FE4E7912BF47A96AE7DD7BAC0AADCB46A2ADC5@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"dhowells@redhat.com" <dhowells@redhat.com>
To: "Vladislav Zolotarov" <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9007 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759128Ab0BYQBf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2010 11:01:35 -0500
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AADCB46A2ADC5@SJEXCHCCR02.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Feb 2010 07:49:48 -0800
"Vladislav Zolotarov" <vladz@broadcom.com> wrote:

> In bnx2x_start_xmit(): right after the "stop queue" there is an smp_mb(), which will bring the cpu0 cache and a fresh fp->tx_bd_cons value to cpu1 and the following if() will return true and the queue will be released from bnx2x_start_xmit() flow.

If I understand correctly what is written in Documentation/memory-barriers.txt
this smp_mb() need to have another "paired" smp_{w}mb() on cpu0 to make value
be updated on cpu1, which is missing.
