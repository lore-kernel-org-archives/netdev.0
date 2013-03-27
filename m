From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: RE: [PATCH net-next] bnx2x: handle spurious interrupts
Date: Wed, 27 Mar 2013 21:08:17 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A52ABF944F@SJEXCHMB10.corp.ad.broadcom.com>
References: <1364408379-4353-1-git-send-email-yuvalmin@broadcom.com>
 <20130327.152716.1731476572805884795.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1192 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752465Ab3C0VI0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 17:08:26 -0400
In-Reply-To: <20130327.152716.1731476572805884795.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Since the driver must request the IRQ prior to enabling HW generation of
> > interrupts, it would still need to ignore every interrupt arriving during that
> > interval.
> 
> This is the real issue.
> 
> request_irq() must not be invoked until you are ready to handle
> interrupts, and this means initializing any and all software
> datastructures that might be accessed in the interrupt handler.
> 
> If this requirement is met, seeing NULL pointers is not possible.

I agree we won't be seeing NULL pointers, but that's only the manifestation of the
problem, not the problem itself - if we would have handled those spurious 
interrupts in the same manner we do regular ones, we might leave HW in an 
unsteady state.

The real issue (well, both are real but this is the one THIS patch tries
solving, while the one you describe is the one I've named `orthogonal') is that 
there exists a scenario in which the HW generates an interrupt although it's 
configured not to do so, and the bnx2x driver shouldn't ACK but rather discard it. 

> I still reject this patch, please fix the fundamental issue instead,
> thanks.

This is of course your prerogative.
We will work on solving both issues.

Thanks,
Yuval
