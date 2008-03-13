From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH] cxgb3: enhance t3_l2t_update to catch netevents in whicharp
 entries have their probe timer expire
Date: Thu, 13 Mar 2008 00:02:45 -0700
Message-ID: <47D8D195.8060808@chelsio.com>
References: <20080311173447.GB13374@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: agospoda@redhat.com, davem@davemloft.net, netdev@vger.kernel.org,
	jeff@garzik.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:15557 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751918AbYCMHFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 03:05:21 -0400
In-Reply-To: <20080311173447.GB13374@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman wrote:
>
> Recently commit 4eb61e0231be536d8116457b67b3e447bbd510dc went in to 
> handle arp
> completion events in the cxgb driver.  This was done to catch arp 
> events for
> which the corresponding entry was marked stale.  This was done to 
> prevent RDMA
> connection failures.  However the preceding patch misses a case.  
> While checking
> for NUD_STALE states allows the processing of arp entries that were 
> completed
> due to arp requests rather than arp replies, it fails to catch arp 
> entries that
> have had their probe timer expire (NUD_PROBE).  It seems the same 
> failure can
> occur in that case.  By changing the check from NUD_CONNECTED|NUD_STALE to
> NUD_VALID, we can catch the previous set of events and add 
> exprired/revalidated
> arp entries to the set of handled cases as well.
>

Hi Neil,

I don't see transitions to NUD_PROBE triggering netevent notifications.
This patch would not alter the current behaviour.
The idea behind the implementation is that NUD_PROBE is considered as
an intermediate state rather than indicating a completion.

I'm inclined to NAK the patch.

Cheers,
Divy


