From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH 1/2] xen-netfront: don't nest queue locks in xennet_connect()
Date: Thu, 3 Jul 2014 17:19:06 +0100
Message-ID: <53B5827A.1040901@citrix.com>
References: <1404313755-27349-1-git-send-email-david.vrabel@citrix.com> <1404313755-27349-2-git-send-email-david.vrabel@citrix.com> <53B44328.6060806@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	=?UTF-8?B?VMO8bGluIMSwemVy?= <tulinizer@gmail.com>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:59577 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759326AbaGCQTJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jul 2014 12:19:09 -0400
In-Reply-To: <53B44328.6060806@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/07/14 18:36, Boris Ostrovsky wrote:
> On 07/02/2014 11:09 AM, David Vrabel wrote:
>> The nesting of the per-queue rx_lock and tx_lock in xennet_connect()
>> is confusing to both humans and lockdep.  The locking is safe because
>> this is the only place where the locks are nested in this way but
>> lockdep still warns.
>>
>> Instead of adding the missing lockdep annotations, refactor the
>> locking to avoid the confusing nesting.  This is still safe, because
>> the xenbus connection state changes are all serialized by the xenwatch
>> thread.
> 
> Tulin (GSoC student) is working on adding some concurrency to the
> xenwatch thread (possibly eliminating it and replacing with a
> workqueue). Which means that we will need to add some sort of
> synchronization in watch callbacks, whenever they are required.

The back/frontend changed callbacks should be serialized with the device
mutex in the same way that the device core does for probe and remove etc.

David
