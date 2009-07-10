From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH for 2.6.31] cxgb3: Fix crash caused by stashing wrong
 netdev_queue
Date: Thu, 09 Jul 2009 17:16:56 -0700 (PDT)
Message-ID: <20090709.171656.216329696.davem@davemloft.net>
References: <4A554A1D.3070703@chelsio.com>
	<adabpnty7qm.fsf_-_@cisco.com>
	<4A565DE9.3040504@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60509
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751066AbZGJAQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 20:16:53 -0400
In-Reply-To: <4A565DE9.3040504@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Thu, 09 Jul 2009 14:15:21 -0700

> Roland Dreier wrote:
>> Commit c3a8c5b6 ("cxgb3: move away from LLTX") exposed a bug in how
>> cxgb3 looks up the netdev_queue it stashes away in a qset during
>> initialization.  For multiport devices, the TX queue index it uses is
>> offset by the first_qset index of each port.  This leads to a crash
>> once LLTX is removed, since hard_start_xmit is called with one TX
>> queue lock held, while the TX reclaim timer task grabs a different
>> (wrong) TX queue lock when it frees skbs.
>>
>> Fix this by removing the first_qset offset used to look up the TX
>> queue passed into t3_sge_alloc_qset() from setup_sge_qsets().
>>   
> 
> Thanks Roland!
> You were very fast to fix it, you beat us.
> 
> Acked-by: Divy Le Ray <divy@chelsio.com>
> 
>> Signed-off-by: Roland Dreier <rolandd@cisco.com>

Applied.
