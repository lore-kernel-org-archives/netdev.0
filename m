From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCHv1] xen-netfront: always keep the Rx ring full
 of requests
Date: Thu, 2 Oct 2014 14:55:47 +0100
Message-ID: <542D5963.10104@citrix.com>
References: <1412256826-18874-1-git-send-email-david.vrabel@citrix.com> <542D7361020000780003C014@mail.emea.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:16203 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751973AbaJBNzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 09:55:50 -0400
In-Reply-To: <542D7361020000780003C014@mail.emea.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/10/14 14:46, Jan Beulich wrote:
>>>> On 02.10.14 at 15:33, <david.vrabel@citrix.com> wrote:
>> A full Rx ring only requires 1 MiB of memory.  This is not enough
>> memory that it is useful to dynamically scale the number of Rx
>> requests in the ring based on traffic rates.
> 
> The performance benefits are nice, but does the above statement
> scale to hundreds of guests with perhaps multiple NICs and/or
> queues?

Yes, because:

a) Even the full 1 MiB is a tiny fraction of a typically modern Linux VM
(for example, the AWS micro instance still has 1 GiB of memory).

b) Netfront would have used up to 1 MiB already even with moderate data
rates (there was no adjustment of target based on memory pressure).

c) Small VMs are going to typically have one VCPU and hence only one queue.

David
