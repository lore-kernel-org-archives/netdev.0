From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] scsi_netlink: Remove dead and buggy code
Date: Tue, 11 Sep 2012 15:40:08 -0700
Message-ID: <878vcggp4n.fsf@xmission.com>
References: <87pq5xjw4m.fsf@xmission.com>
	<20120910.150700.1197774171539303770.davem@davemloft.net>
	<1347314879.3038.74.camel@dabdike.int.hansenpartnership.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	James.Smart@Emulex.Com, linux-scsi@vger.kernel.org
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:35835 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788Ab2IKWkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 18:40:24 -0400
In-Reply-To: <1347314879.3038.74.camel@dabdike.int.hansenpartnership.com>
	(James Bottomley's message of "Mon, 10 Sep 2012 23:07:59 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Bottomley <James.Bottomley@HansenPartnership.com> writes:

> On Mon, 2012-09-10 at 15:07 -0400, David Miller wrote:
>> From: ebiederm@xmission.com (Eric W. Biederman)
>> Date: Fri, 07 Sep 2012 15:39:21 -0700
>> 
>> > 
>> > The scsi netlink code confuses the netlink port id with a process id,
>> > going so far as to read NETLINK_CREDS(skb)->pid instead of the correct
>> > NETLINK_CB(skb).pid.  Fortunately it does not matter because nothing
>> > registers to respond to scsi netlink requests.
>> > 
>> > The only interesting use of the scsi_netlink interface is
>> > fc_host_post_vendor_event which sends a netlink multicast message.
>> > 
>> > Since nothing registers to handle scsi netlink messages kill all of the
>> > registration logic, while retaining the same error handling behavior
>> > preserving the userspace visible behavior and removing all of the
>> > confused code that thought a netlink port id was a process id.
>> > 
>> > This was tested with a kernel allyesconfig build which had no problems.
>> > 
>> > Cc: James Bottomley <James.Bottomley@parallels.com>
>> > Cc: James Smart <James.Smart@Emulex.Com>
>> > Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> 
>> James et al., please review and ACK.
>
> I'll defer to the decision of James Smart and the other FC contributors,
> since the FC transport class is really the only one using a netlink
> interface.

So just for curiosity I searched the entire git history for scsi_nl_add_
and the only commit that I found was the addition of that code to the
tree in August of 2008.

Does anyone have any reason to keep scsi_nl_add_transport or
scsi_nl_add_driver that have never been used in the 4 years since
they have been added?

Eric
