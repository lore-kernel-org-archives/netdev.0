From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] cxgb3: enhance t3_l2t_update to catch netevents in
	whicharp entries have their probe timer expire
Date: Thu, 13 Mar 2008 13:47:10 -0400
Message-ID: <20080313174710.GA6514@hmsreliant.think-freely.org>
References: <20080311173447.GB13374@hmsreliant.think-freely.org> <47D8D195.8060808@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: agospoda@redhat.com, davem@davemloft.net, netdev@vger.kernel.org,
	jeff@garzik.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2927 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752189AbYCMRsm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Mar 2008 13:48:42 -0400
Content-Disposition: inline
In-Reply-To: <47D8D195.8060808@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 13, 2008 at 12:02:45AM -0700, Divy Le Ray wrote:
> Neil Horman wrote:
>>
>> Recently commit 4eb61e0231be536d8116457b67b3e447bbd510dc went in to handle 
>> arp
>> completion events in the cxgb driver.  This was done to catch arp events 
>> for
>> which the corresponding entry was marked stale.  This was done to prevent 
>> RDMA
>> connection failures.  However the preceding patch misses a case.  While 
>> checking
>> for NUD_STALE states allows the processing of arp entries that were 
>> completed
>> due to arp requests rather than arp replies, it fails to catch arp entries 
>> that
>> have had their probe timer expire (NUD_PROBE).  It seems the same failure 
>> can
>> occur in that case.  By changing the check from NUD_CONNECTED|NUD_STALE to
>> NUD_VALID, we can catch the previous set of events and add 
>> exprired/revalidated
>> arp entries to the set of handled cases as well.
>>
>
> Hi Neil,
>
> I don't see transitions to NUD_PROBE triggering netevent notifications.
> This patch would not alter the current behaviour.
> The idea behind the implementation is that NUD_PROBE is considered as
> an intermediate state rather than indicating a completion.
>
> I'm inclined to NAK the patch.
Oh, you're right.  I was thinking that the nud_state & (NUD_INCOMPPLETE
|NUD_PROBE) clause would set the notify flag and we'd get the notification.  But
to fall into that clause, we'd need to also exceede our max probe count, which
then puts us into NUD_FAILED state.

Patch is recinded.

Regards
Neil

>
> Cheers,
> Divy
>

-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
