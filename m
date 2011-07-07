From: Yong Wang <yongwang@vmware.com>
Subject: RE: [Pv-drivers] [PATCH] vmxnet3: round down # of queues to power
 of two
Date: Wed, 6 Jul 2011 18:53:57 -0700
Message-ID: <A66AA49650CD894E9943A431D2F0B1E9026DAEC5DC@exch-mbx-111.vmware.com>
References: <alpine.LRH.2.00.1107061751120.3509@sbhatewara-dev1.eng.vmware.com>
 <201107061808.39918.dtor@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Shreyas Bhatewara <sbhatewara@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dmitry Torokhov <dtor@vmware.com>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:45620 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752916Ab1GGBx7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2011 21:53:59 -0400
Received: from mailhost3.vmware.com (mailhost3.vmware.com [10.16.27.45])
	by smtp-outbound-1.vmware.com (Postfix) with ESMTP id A15711C003
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2011 18:53:59 -0700 (PDT)
In-Reply-To: <201107061808.39918.dtor@vmware.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just want to point out that rounddown_pow_of_two() returns 0 when (1) the input is 1; and (2) the __buildin_constant_p(n) path is taken.  In the vmxnet3 case, even if num_rx_queues is 1, we are safe as its value is not known to be constant at compile time and 1 will be returned by taking the other path (1UL << (fls_long(n) - 1)). The original check of power_of_two is there just to be on the safe side.

Related to this, I wonder if we should always return 1 when the input is 1 (1 is also a power of two as 2^0). I don't have the history of this API though and curious if there are any users of this API that depend on this behavior?

Thanks,
Yong

> -----Original Message-----
> From: Dmitry Torokhov [mailto:dtor@vmware.com]
> Sent: Wednesday, July 06, 2011 6:09 PM
> To: pv-drivers@vmware.com
> Cc: Shreyas Bhatewara; netdev@vger.kernel.org; Yong Wang
> Subject: Re: [Pv-drivers] [PATCH] vmxnet3: round down # of queues to power of
> two
> 
> On Wednesday, July 06, 2011 05:58:51 PM Shreyas Bhatewara wrote:
> 
> >
> > +	if (!is_power_of_2(num_rx_queues))
> > +		num_rx_queues = rounddown_pow_of_two(num_rx_queues);
> > +
> 
> No need to do the check, just do:
> 
> 	num_rx_queues = rounddown_pow_of_two(num_rx_queues);
> 
> Thanks,
> Dmitry
