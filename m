From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: LRO ip_summed
Date: Tue, 5 Feb 2008 10:45:56 +0100
Message-ID: <200802051045.56654.ossthema@de.ibm.com>
References: <BAY121-W366A043ECDC160494B1EFAB6320@phx.gbl> <200802041014.23989.ossthema@de.ibm.com> <BAY121-W3321045858D4A665892759B62C0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="windows-1255"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kostya B <bkostya@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:53850 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753840AbYBEJqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 04:46:01 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m159k0O2188116
	for <netdev@vger.kernel.org>; Tue, 5 Feb 2008 09:46:00 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m159k0Pn4833504
	for <netdev@vger.kernel.org>; Tue, 5 Feb 2008 09:46:00 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m159jvme022517
	for <netdev@vger.kernel.org>; Tue, 5 Feb 2008 09:45:57 GMT
In-Reply-To: <BAY121-W3321045858D4A665892759B62C0@phx.gbl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 05 February 2008 09:56, Kostya B wrote:
> 
> 1. Let's assume a driver which has a HW csum capability, however it has a privilege to assign any value for ip_summed.
> For example the driver assigns "unnecessary" for most of the packets, however it fails to verify the packets less than 96 bytes ("checksum_none").
> Now, the LRO will aggregate all of them and assign the value "used for all aggregated packets" - that is wrong, 
> 
> Of course, it is possible to avoid that situation in driver, however [proposal] from the point of view of the *generic* LRO it could be better to check each newly aggregated skb whether it has the same ip_summed as the first one (preserve coherency). Thus, there is no need to keep ip_summed field in the  struct net_lro_mgr.

Yes, checking if ip_summed is equal for all aggregated packets would work
for the "aggregating SKB" mode. For the other mode this information is currently 
not passed to LRO but could of course be provided as parameter by the driver.
The question is if there is any HW which would benefit from this (meaning multiple
ip_summed values for TCP packets of different sizes) so that this additional
check is really useful. The less required checks the better.

> 
> 2. Now, when a skb could not be aggregated (modes: aggregating SKBs) I think where's no need to override its original ip_summed (see "out" label of __lro_proc_skb()) The comment says  "Original SKB has to be posted to stack". I would be wrong, but I don't get the reason to possible change of ip_summed.
> 

Good point. This assignment seems to be unnecessary.

Regards,
Jan-Bernd
