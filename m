From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH] xen-netback: fix race between napi_complete() and interrupt
 handler
Date: Tue, 25 Mar 2014 15:08:15 +0000
Message-ID: <53319BDF.9040001@citrix.com>
References: <1395756505-21573-1-git-send-email-david.vrabel@citrix.com> <20140325145021.GF31766@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:36125 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581AbaCYPIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 11:08:18 -0400
In-Reply-To: <20140325145021.GF31766@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/03/14 14:50, Wei Liu wrote:
> You forgot to target this patch to "net" tree in subject line.
> 
> On Tue, Mar 25, 2014 at 02:08:25PM +0000, David Vrabel wrote:
>> When the NAPI budget was not all used, xenvif_poll() would call
>> napi_complete() /after/ enabling the interrupt.  This resulted in a
>> race between the napi_complete() and the napi_schedule() in the
>> interrupt handler.  The use of local_irq_save/restore() avoided by
>> race iff the handler is running on the same CPU but not if it was
>> running on a different CPU.
>>
> 
> OK, I understand this issue now. You mentioned it in the other email
> which made me a bit confused.
> 
> Just curious, how do you trigger this? By re-binding the interrupt to
> another CPU when xenvif_poll is running? I used to run irqbalance (the
> one that works with xen virtual interrupt) but could not trigger a race.
> Probably the race window is too small to trigger?

I haven't seen the race occur, but I've not tried to trigger it.

It may be that as Zoltan says, that the race is harmless but I still
think avoiding the race entirely is preferable.

David
