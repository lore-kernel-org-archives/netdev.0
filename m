From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: RE: [PATCH net 5/8] qlcnic: Fix reset recovery after transmit
 timeout
Date: Thu, 9 May 2013 06:21:58 +0000
Message-ID: <262CB373A6D1F14F9B81E82F74F77D5A4B3669@avmb2.qlogic.org>
References: <1367956506-3290-1-git-send-email-shahed.shaikh@qlogic.com>
	<1367956506-3290-6-git-send-email-shahed.shaikh@qlogic.com>
 <20130508.120658.318501645917412400.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.32.180.31] ([216.32.180.31]:54841 "EHLO
	va3outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751040Ab3EIGXx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 May 2013 02:23:53 -0400
In-Reply-To: <20130508.120658.318501645917412400.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, May 09, 2013 12:37 AM
> To: Shahed Shaikh
> Cc: netdev; Dept-NX Linux NIC Driver; Sony Chacko
> Subject: Re: [PATCH net 5/8] qlcnic: Fix reset recovery after transmit timeout
> 
> From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> Date: Tue, 7 May 2013 15:55:03 -0400
> 
> > @@ -435,10 +435,7 @@ static void qlcnic_83xx_idc_attach_driver(struct
> qlcnic_adapter *adapter)
> >  	}
> >  done:
> >  	netif_device_attach(netdev);
> > -	if (netif_running(netdev)) {
> > -		netif_carrier_on(netdev);
> > -		netif_wake_queue(netdev);
> > -	}
> > +	adapter->netdev->trans_start = jiffies;
> >  }
> >
> >  static int qlcnic_83xx_idc_enter_failed_state(struct qlcnic_adapter
> > *adapter,
> 
> This is not right.
> 
> Multiqueue aware drivers should never access netdev->trans_start directly,
> and I see several such writes in this driver.
> 
> Anything you write here will be totally ignored by the rest of the kernel,
> because this value is overwritten by every call to dev_trans_start() which is
> the only valid method by which to determine this value.
> 
> dev_trans_start() walks all of the transmit queues, recording the most recent
> txq->trans_start timestamp in netdev->trans_start.
> 
> So if you write netdev->trans_start in your driver, it does nothing, because
> even the dev_watchdog() time is going to inspect the per-queue
> txq->trans_start values and ignore the netdev->trans_start value for
> devices whose driver suppports multiqueue as qlcnic does.

Hi David,

We will resubmit the current patch after removing access to netdev->trans_start.
We will fix the same issue in the rest of the driver code in a follow-up patch.

Thanks,
Shahed
