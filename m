From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC net-next 3/3] rcv path changes for vrf traffic
Date: Tue, 09 Jun 2015 00:13:08 +0200
Message-ID: <1433801588.2014273.290219489.63F713EC@webmail.messagingengine.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com>
 <87eae7a7a03708bda5560a5ea43b0fcac705c80d.1433561681.git.shm@cumulusnetworks.com>
 <1433793517.4616.4.camel@stressinduktion.org>
 <20150608.150518.424856528462798668.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Ahern <dsahern@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	andy gospodarek <gospo@cumulusnetworks.com>,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:48267 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752966AbbFHWNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 18:13:09 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id DA2DC20FC9
	for <netdev@vger.kernel.org>; Mon,  8 Jun 2015 18:13:08 -0400 (EDT)
In-Reply-To: <20150608.150518.424856528462798668.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 9, 2015, at 00:05, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Mon, 08 Jun 2015 21:58:37 +0200
> 
> > +static inline u32 ipv4_idev_rt_table(const struct net_device *dev)
> > +{
> > +       u32 table_id;
> > +
> > +       rcu_read_lock();
> > +       table_id = __in_dev_get_rcu(dev)->rt_table_id;
> > +       rcu_read_unlock();
> > +
> > +       return table_id != RT_TABLE_UNSPEC ? table_id : RT_TABLE_LOCAL;
> > +}
> 
> It's a real shame you have to do all of this RCU locking and inetdev
> deref, because in more than half of the call sites the idev is already
> available.

I agree, I was not happy with that either.

It is easy to move the rt_table_id to net_device and use the same one
for IPv6.
This would force people to build symmetric routing configurations. I was
striving for
maximum flexibility first but I don't really think this matters here.

Bye,
Hannes
