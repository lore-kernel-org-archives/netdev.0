From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 09/17] net: Allow userns root control of the core of the network stack.
Date: Fri, 16 Nov 2012 06:32:21 -0800
Message-ID: <871uft8vpm.fsf@xmission.com>
References: <87d2zd8zwn.fsf@xmission.com>
	<1353070992-5552-1-git-send-email-ebiederm@xmission.com>
	<1353070992-5552-9-git-send-email-ebiederm@xmission.com>
	<50A645C2.1000604@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.linux-foundation.org>
To: Glauber Costa <glommer@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:48524 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243Ab2KPOcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 09:32:35 -0500
In-Reply-To: <50A645C2.1000604@parallels.com> (Glauber Costa's message of
	"Fri, 16 Nov 2012 17:55:14 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Glauber Costa <glommer@parallels.com> writes:

> On 11/16/2012 05:03 PM, Eric W. Biederman wrote:
>> +	if (!capable(CAP_NET_ADMIN))
>> +		return -EPERM;
>> +
>>  	return netdev_store(dev, attr, buf, len, change_tx_queue_len);
>
> You mean ns_capable here?

No.  There I meant capable.

I deliberately call capable here because I don't understand what
the tx_queue_len well enough to be certain it is safe to relax
that check to be just ns_capable.

My get feel is that allowing an unprivileged user to be able to
arbitrarily change the tx_queue_len on a networking device would be a
nice way to allow queuing as many network packets as you would like with
kernel memory and DOSing the machine.

So since with a quick read of the code I could not convince myself it
was safe to allow unprivilged users to change tx_queue_len I left it
protected by capable.  While at the same time I relaxed the check in
netdev_store to be ns_capable.

Eric
