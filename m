From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v4] af_mpls: fix undefined reference to
 ip6_route_output
Date: Wed, 29 Jul 2015 00:22:43 +0200
Message-ID: <1438122163.2621886.335716241.03B1A616@webmail.messagingengine.com>
References: <1438065624-38229-1-git-send-email-roopa@cumulusnetworks.com>
 <1438088676.25794.19.camel@stressinduktion.org>
 <55B7D7FA.8070301@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, tgraf@suug.ch, netdev@vger.kernel.org
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:59659 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751135AbbG1WWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 18:22:44 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 1BAB120999
	for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 18:22:44 -0400 (EDT)
In-Reply-To: <55B7D7FA.8070301@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi roopa,

On Tue, Jul 28, 2015, at 21:28, roopa wrote:
> On 7/28/15, 6:04 AM, Hannes Frederic Sowa wrote:
> > Can't you simply use ipv6_stub_impl.ipv6_dst_lookup with sk=NULL to do
> > that and don't have a run-time dependency on IPv6 at all (for the cost
> > of a function pointer).
>   ipv6_stub_impl.ipv6_dst_lookup seems to require sk today.
> But it only needs it to get 'net' in the beginning and sk is optional 
> afterwards.
> I will submit a patch to add 'net' as an arg  to ipv6_dst_lookup.
> Users of ipv6_dst_lookup are few and that seems like an easy change and 
> helps my patch.
> If you or others think otherwise, pls let me know.

No need to extend this function at any cost. Simply add your own
function pointer to the struct if needed.

Probably you have to move the ipv6_stub = &ipv6_stub_impl;
initialization in inet6_init down so you don't expose the function
pointer too early and thus it races with initialization (and error
handling seems to be incorrect in this function, too).

Thanks,
Hannes
