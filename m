From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH 2/2] xen-netback: cancel the credit
 timer when taking the vif down
Date: Thu, 14 Feb 2013 14:15:22 +0000
Message-ID: <511CFF8A02000078000BE4B2@nat28.tlf.novell.com>
References: <1360847938-11185-1-git-send-email-david.vrabel@citrix.com>
 <1360847938-11185-3-git-send-email-david.vrabel@citrix.com>
 <1360849999.16636.135.camel@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "David Vrabel" <david.vrabel@citrix.com>,
	"Wei Liu (3P)" <wei.liu@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"KonradRzeszutek Wilk" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ian Campbell" <Ian.Campbell@citrix.com>,
	"Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:46199 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249Ab3BNOO0 convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Thu, 14 Feb 2013 09:14:26 -0500
In-Reply-To: <1360849999.16636.135.camel@zion.uk.xensource.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 14.02.13 at 14:53, Wei Liu <wei.liu2@citrix.com> wrote:
> On Thu, 2013-02-14 at 13:18 +0000, David Vrabel wrote:
>> From: David Vrabel <david.vrabel@citrix.com>
>> 
>> If the credit timer is left armed after calling
>> xen_netbk_remove_xenvif(), then it may fire and attempt to schedule
>> the vif which will then oops as vif->netbk == NULL.
>> 
>> This may happen both in the fatal error path and during normal
>> disconnection from the front end.
>> 
>> The sequencing during shutdown is critical to ensure that: a)
>> vif->netbk doesn't become unexpectedly NULL; and b) the net device/vif
>> is not freed.
>> 
>> 1. Mark as unschedulable (netif_carrier_off()).
>> 2. Synchronously cancel the timer.
>> 3. Remove the vif from the schedule list.
>> 4. Remove it from it netback thread group.
>> 5. Wait for vif->refcnt to become 0.
>> 
>> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> 
> You would need to reinitialize the timer in xenvif_up, given that user
> might `ifconfig vifX.X down; ifconfig vifX.X up`.

Which gets us to another aspect of the original fix that I don't
think was considered: Is there anything preventing the interface
to be brought back up after fatal_tx_err() shut it down?

Jan
