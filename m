From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: ixgbe: fixup hard dependencies on supporting 8 traffic classes
Date: Tue, 11 Oct 2011 23:58:33 -0700
Message-ID: <4E953A99.4030402@intel.com>
References: <20111012063555.GA23359@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:28152 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751106Ab1JLG6e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Oct 2011 02:58:34 -0400
In-Reply-To: <20111012063555.GA23359@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/11/2011 11:35 PM, Dan Carpenter wrote:
> Hello John Fastabend,
> 
> This is a semi-automatic email about new static checker warnings.
> 
> The patch 32701dc2e616: "ixgbe: fixup hard dependencies on supporting
> 8 traffic classes" from Sep 27, 2011, leads to the following Smatch
> complaint:
> 
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c +3366 ixgbe_configure_dcb()
> 	 error: we previously assumed 'adapter->ixgbe_ieee_ets' could be null (see line 3357)
> 
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>   3356	
>   3357			if (adapter->ixgbe_ieee_ets) {
>                             ^^^^^^^^^^^^^^^^^^^^^^^
> Null check.
> 
>   3358				struct ieee_ets *ets = adapter->ixgbe_ieee_ets;
>   3359				int max_frame = dev->mtu + ETH_HLEN + ETH_FCS_LEN;
>   3360	
>   3361				ixgbe_dcb_hw_ets(&adapter->hw, ets, max_frame);
>   3362			}
>   3363	
>   3364			if (adapter->ixgbe_ieee_pfc) {
>   3365				struct ieee_pfc *pfc = adapter->ixgbe_ieee_pfc;
>   3366				u8 *prio_tc = adapter->ixgbe_ieee_ets->prio_tc;
>                                               ^^^^^^^^^^^^^^^^^^^^^^^^^
> New dereference.
> 
>   3367	
>   3368				ixgbe_dcb_hw_pfc_config(&adapter->hw, pfc->pfc_en,
> 
> regards,
> dan carpenter
> 

Actually both structures ixgbe_ieee_ets and ixgbe_ieee_pfc get initialized
at the same time. So no null dereference will occur. That said this snippit
should be fixed.

I'll send a patch to JeffK. Thanks for the catch Dan.

.John
