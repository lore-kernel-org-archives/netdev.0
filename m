From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next] ipv6: allow routes to be configured with
 expire values
Date: Thu, 17 Dec 2015 16:26:50 -0500 (EST)
Message-ID: <20151217.162650.526302130376762794.davem@davemloft.net>
References: <1450285432.23793.12.camel@redhat.com>
	<20151217.150826.320110242014234511.davem@davemloft.net>
	<1450383837.28806.4.camel@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lucien.xin@gmail.com, netdev@vger.kernel.org,
	hannes@stressinduktion.org
To: dcbw@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932670AbbLQV0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 16:26:51 -0500
In-Reply-To: <1450383837.28806.4.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Williams <dcbw@redhat.com>
Date: Thu, 17 Dec 2015 14:23:57 -0600

> On Thu, 2015-12-17 at 15:08 -0500, David Miller wrote:
>> That brings up an interesting issue, and I do not agree that we
>> should
>> publish the value for the purpose of determining if the kernel
>> supports
>> it or not.
> 
> That said, userspace still needs to read back the EXPIRES attribute, if
> only for iproute.  The program setting RTA_EXPIRES isn't the only thing
> that wants to know about the route's details.

Agreed.

>> I'm almost positive that the right thing to do is to unilaterally
>> making nlmsg_parse() error out on out-of-range attribute type
>> numbers,
>> and then backport that to all -stable branches.
> 
> This works for one attribute because then userspace gets an error like
> EOPNOTSUPP or something.  But which attribute caused it?  Does
> userspace then have to retry the operation a couple times with all the
> different combinations of potentially unsupported options?
> 
> If we're going to error out on unrecognized options, I'd really like to
> see some kind of netlink features bitmap or something that positively
> indicates which options the kernel will accept.

Also agree.  But it has to be really simple and trivial so that -stable
backports are possible.
