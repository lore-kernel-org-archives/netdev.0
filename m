From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Mon, 08 Oct 2007 21:31:09 -0400
Message-ID: <470AD9DD.2080707@garzik.org>
References: <1191868010.4335.33.camel@localhost>	 <D5C1322C3E673F459512FB59E0DDC32903BC1234@orsmsx414.amr.corp.intel.com>	 <1191876530.4373.58.camel@localhost>	 <D5C1322C3E673F459512FB59E0DDC32903BC14AC@orsmsx414.amr.corp.intel.com> <1191886845.4373.138.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	mcarlson@broadcom.com, mchan@broadcom.com,
	general@lists.openfabrics.org, tgraf@suug.ch,
	randy.dunlap@oracle.com, sri@us.ibm.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51181 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751121AbXJIBbq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2007 21:31:46 -0400
In-Reply-To: <1191886845.4373.138.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> The challenge to deal with is that netdevices, filters, the queues and
> scheduler are closely inter-twined. So it is not just the scheduling
> region and QDISC_RUNNING. For example, lets pick just the filters
> because they are simple to see: You need to attach them to something -
> whatever that is, you then need to synchronize against config and
> multiple cpus trying to use them. You could: 
> a) replicate them across cpus and only lock on config, but you are
> wasting RAM then

I think you've pretty much bought into the cost of wasting RAM, when 
doing multiple TX rings.  So logic implies associated costs, like the 
ones you describe, come along for the ride.


> b) attach them to rings instead of netdevices - but that makes me wonder
> if those subqueues are now going to become netdevices. This also means
> you change all user space interfaces to know about subqueues. If you
> recall this was a major contention in our earlier discussion.

That's definitely a good question, and I honestly don't see any easy 
solutions.

Multiple net devices makes a -lot- of things easier, with regards to 
existing infrastructure, but it also imposes potentially annoying 
administrative burdens:  Not only must each interface be set up 
individually, but the userland apps must be made aware of this unique 
method of concurrency.

	Jeff




