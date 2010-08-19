From: Brian King <brking@linux.vnet.ibm.com>
Subject: Re: [patch 04/20] ibmveth: Add tx_copybreak
Date: Thu, 19 Aug 2010 08:34:48 -0500
Message-ID: <4C6D32F8.1020409@linux.vnet.ibm.com>
References: <20100819072456.317416634@samba.org> <20100819072503.937364037@samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Santiago Leon <santil@linux.vnet.ibm.com>, netdev@vger.kernel.org
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:43732 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751166Ab0HSNe4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Aug 2010 09:34:56 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7JDSp4u030013
	for <netdev@vger.kernel.org>; Thu, 19 Aug 2010 09:28:51 -0400
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7JDYtoC101282
	for <netdev@vger.kernel.org>; Thu, 19 Aug 2010 09:34:55 -0400
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7JDYsfL024665
	for <netdev@vger.kernel.org>; Thu, 19 Aug 2010 07:34:55 -0600
In-Reply-To: <20100819072503.937364037@samba.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/2010 02:25 AM, Anton Blanchard wrote:
> Use the existing bounce buffer if we send a buffer under a certain size.
> This saves the overhead of a TCE map/unmap.
> 
> I can't see any reason for the wmb() in the bounce buffer case, if we need
> a barrier it will be before we call h_send_logical_lan but we have
> nothing in the common case. Remove it.
> 
> Signed-off-by: Anton Blanchard <anton@samba.org>
> ---
> 
> Index: powerpc.git/drivers/net/ibmveth.c
> ===================================================================
> --- powerpc.git.orig/drivers/net/ibmveth.c	2010-08-10 18:35:52.293272470 +1000
> +++ powerpc.git/drivers/net/ibmveth.c	2010-08-10 18:35:55.440741255 +1000
> @@ -117,6 +117,11 @@ MODULE_DESCRIPTION("IBM i/pSeries Virtua
>  MODULE_LICENSE("GPL");
>  MODULE_VERSION(ibmveth_driver_version);
> 
> +static unsigned int tx_copybreak __read_mostly = 128;

Where did the 128 come from? I thought I heard the 2k value discussed in
the past.

Thanks,

Brian

-- 
Brian King
Linux on Power Virtualization
IBM Linux Technology Center


