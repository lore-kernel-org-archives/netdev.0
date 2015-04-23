From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] ibmveth: Fix off-by-one error in ibmveth_change_mtu()
Date: Thu, 23 Apr 2015 11:42:45 -0400 (EDT)
Message-ID: <20150423.114245.1826557896621397900.davem@davemloft.net>
References: <1429764185-597-1-git-send-email-david@gibson.dropbear.id.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@au1.ibm.com, tlfalcon@linux.vnet.ibm.com,
	michael@ellerman.id.au, linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: david@gibson.dropbear.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42035 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965608AbbDWPmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 11:42:47 -0400
In-Reply-To: <1429764185-597-1-git-send-email-david@gibson.dropbear.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Gibson <david@gibson.dropbear.id.au>
Date: Thu, 23 Apr 2015 14:43:05 +1000

> AFAIK the PAPR document which defines the virtual device interface used by
> the ibmveth driver doesn't specify a specific maximum MTU.  So, in the
> ibmveth driver, the maximum allowed MTU is determined by the maximum
> allocated buffer size of 64k (corresponding to one page in the common case)
> minus the per-buffer overhead IBMVETH_BUFF_OH (which has value 22 for 14
> bytes of ethernet header, plus 8 bytes for an opaque handle).
> 
> This suggests a maximum allowable MTU of 65514 bytes, but in fact the
> driver only permits a maximum MTU of 65513.  This is because there is a <
> instead of an <= in ibmveth_change_mtu(), which only permits an MTU which
> is strictly smaller than the buffer size, rather than allowing the buffer
> to be completely filled.
> 
> This patch fixes the buglet.
> 
> Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
> Acked-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Applied, thank you.
