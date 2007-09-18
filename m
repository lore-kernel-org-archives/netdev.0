From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: new NAPI interface broken
Date: Tue, 18 Sep 2007 18:15:45 +0200
Message-ID: <200709181815.45954.ossthema@de.ibm.com>
References: <200709071137.02801.ossthema@de.ibm.com> <20070914.151252.85399360.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	themann@de.ibm.com, raisch@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:34422 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759409AbXIRQQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 12:16:23 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l8IGGJRs241196
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 16:16:19 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8IGGJgw2838564
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 17:16:19 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8IGG2u4013318
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 17:16:03 +0100
In-Reply-To: <20070914.151252.85399360.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Saturday 15 September 2007 00:12, David Miller wrote:
> Ok, for now I'm going to try and deal with this by reverting
> the list handling to something approximating the old NAPI
> code, as per the patch below.
> 
> I've only quickly test booted into this kernel on my workstation.
> So take care when trying it out.
> 
> I took the liberty to add some assertions and comments all over
> wrt. list and quota handling.  One thing to note that (and this
> was true previously too) that if ->poll() uses the whole quota
> it _MUST_ _NOT_ modify the NAPI state by doing a complete or
> reschedule.  The net_rx_action code still owns the NAPI state in
> that case, and therefore is allowed to make modifications to the
> ->poll_list.

I'm currently updating the eHEA polling function to work with this
scheme. Up to now we had sort of a quota for or TX refill part as well,
which was also done in the poll function. This was possible as the device
could be scheduled again even if the quota has not been used
completely. If I got it right this is not longer possible. 
The idea was to benefit from the same "fairness" scheme of NAPI as it is
done for the RX side.

One other thing I observed is that I can not unload the module as the
ref counter of the eth device is too low. I haven't tracked down the 
source of this problem yet.

Regards,
Jan-Bernd
