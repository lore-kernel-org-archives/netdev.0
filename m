From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: new NAPI interface broken
Date: Wed, 19 Sep 2007 17:43:51 +0200
Message-ID: <200709191743.51917.ossthema@de.ibm.com>
References: <200709071137.02801.ossthema@de.ibm.com> <200709181815.45954.ossthema@de.ibm.com> <adafy1ak6u8.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	themann@de.ibm.com, raisch@de.ibm.com
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:10005 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761207AbXISPoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 11:44:17 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l8JFiFVZ157878
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 15:44:15 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8JFiFDM2306104
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 16:44:15 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8JFhwti011491
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 16:43:59 +0100
In-Reply-To: <adafy1ak6u8.fsf@cisco.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 19 September 2007 17:33, Roland Dreier wrote:
>  > One other thing I observed is that I can not unload the module as the
>  > ref counter of the eth device is too low. I haven't tracked down the 
>  > source of this problem yet.
> 
> I suspect that this is because netif_rx_reschedule() was missing a
> dev_hold() to match the dev_put() in netif_rx_complete().  Dave merged
> a fix for that problem yesterday, so current net-2.6.24 should be OK.
> Let us know if it's not OK, because then there's another bug...
> 
>  - R.
> 

When I applied this netif_rx_reschedule fix this problem did not occur
anymore (module could be unloaded). So I guess I hit the problem you
described.

Thanks,
Jan-Bernd
