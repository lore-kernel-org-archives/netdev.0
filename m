From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next] ipv6: allow routes to be configured with
 expire values
Date: Thu, 17 Dec 2015 15:08:26 -0500 (EST)
Message-ID: <20151217.150826.320110242014234511.davem@davemloft.net>
References: <3b977653c7ade52e180d754eb660ec66af212e94.1450259411.git.lucien.xin@gmail.com>
	<1450285432.23793.12.camel@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lucien.xin@gmail.com, netdev@vger.kernel.org,
	hannes@stressinduktion.org
To: dcbw@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56416 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754643AbbLQUIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 15:08:30 -0500
In-Reply-To: <1450285432.23793.12.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Williams <dcbw@redhat.com>
Date: Wed, 16 Dec 2015 11:03:52 -0600

> On Wed, 2015-12-16 at 17:50 +0800, Xin Long wrote:
>> Add the support for adding expire value to routes,  requested by
>> Tom Gundersen <teg@jklm.no> for systemd-networkd, and NetworkManager
>> wants it too.
>> 
>> implement it by adding the new RTNETLINK attribute RTA_EXPIRES.
> 
> Could you also add bits to send RTA_EXPIRES back to userspace in the
> route dump in rt6_fill_node(), so that userspace can figure out when
> RTA_EXPIRES is supported or not?
> 
> (obviously having it there isn't foolproof as if there are no routes on
> the system yet userspace can't figure out support, but it's better than
> nothing...)

That brings up an interesting issue, and I do not agree that we should
publish the value for the purpose of determining if the kernel supports
it or not.

We need to come up with a policy for handling unknown attributes
because what we do now doesn't work.

I'm almost positive that the right thing to do is to unilaterally
making nlmsg_parse() error out on out-of-range attribute type numbers,
and then backport that to all -stable branches.
