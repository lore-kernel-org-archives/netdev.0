From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: RE: [RFC PATCH] bnx2x: fix tx queue locking and memory barriers
Date: Thu, 25 Feb 2010 08:14:58 -0800
Message-ID: <8628FE4E7912BF47A96AE7DD7BAC0AADCB46A2ADD1@SJEXCHCCR02.corp.ad.broadcom.com>
References: <20100225140834.0169e9f2@dhcp-lab-109.englab.brq.redhat.com>
 <20100225.021822.66777947.davem@davemloft.net>
 <20100225164015.3991ab5e@dhcp-lab-109.englab.brq.redhat.com>
 <8628FE4E7912BF47A96AE7DD7BAC0AADCB46A2ADC5@SJEXCHCCR02.corp.ad.broadcom.com>
 <20100225170308.6294aa1a@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"dhowells@redhat.com" <dhowells@redhat.com>
To: "Stanislaw Gruszka" <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4291 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932831Ab0BYQPM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 11:15:12 -0500
In-Reply-To: <20100225170308.6294aa1a@dhcp-lab-109.englab.brq.redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct. There a missing barrier in bnx2x_tx_int(). I'll create a proper patch shortly. 

Thanks. 

> -----Original Message-----
> From: Stanislaw Gruszka [mailto:sgruszka@redhat.com] 
> Sent: Thursday, February 25, 2010 6:03 PM
> To: Vladislav Zolotarov
> Cc: David Miller; netdev@vger.kernel.org; Eilon Greenstein; 
> dhowells@redhat.com
> Subject: Re: [RFC PATCH] bnx2x: fix tx queue locking and 
> memory barriers
> 
> On Thu, 25 Feb 2010 07:49:48 -0800
> "Vladislav Zolotarov" <vladz@broadcom.com> wrote:
> 
> > In bnx2x_start_xmit(): right after the "stop queue" there 
> is an smp_mb(), which will bring the cpu0 cache and a fresh 
> fp->tx_bd_cons value to cpu1 and the following if() will 
> return true and the queue will be released from 
> bnx2x_start_xmit() flow.
> 
> If I understand correctly what is written in 
> Documentation/memory-barriers.txt
> this smp_mb() need to have another "paired" smp_{w}mb() on 
> cpu0 to make value
> be updated on cpu1, which is missing.
> 
> 
