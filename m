From: Jeff Garzik <jgarzik@pobox.com>
Subject: TOE, etc. (was Re: [PATCH Round 3 0/2][RFC] Network Event Notifier
 Mechanism)
Date: Wed, 28 Jun 2006 00:18:25 -0400
Message-ID: <44A20311.5050301@pobox.com>
References: <20060627205050.30723.25753.stgit@stevo-desktop> <E1FvQBu-00018u-00@gondolin.me.apana.org.au> <20060628030400.GA4474@gondor.apana.org.au> <44A1F669.8070606@pobox.com> <20060628033708.GA4922@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steve Wise <swise@opengridcomputing.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:30895 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932718AbWF1ESf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2006 00:18:35 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net
In-Reply-To: <20060628033708.GA4922@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Tue, Jun 27, 2006 at 11:24:25PM -0400, Jeff Garzik wrote:
>> I don't see how that position has changed?
>>
>> http://linux-net.osdl.org/index.php/TOE
> 
> Well I must say that RDMA over TCP smells very much like TOE.  They've
> got an ARP table, a routing table, and presumably a TCP stack.

A PCI device that presents itself as a SCSI controller, but under the 
hood is really iSCSI-over-TCP smells like TOE.  Running a virtualized 
Linux guest on top of a proprietary stack [which provides networking 
services to guests] also smells like TOE.  :)

If a TOE vendors wants to do TOE in a way that is transparent to the 
kernel, more power to them.  Such non-Linux TCP stack solutions still 
suffer many of the problems listed at the web page above, but at least 
they impose no burden on kernel maintenance.

i.e. we really _do not_ want to get into the habit of co-managing arp 
tables, routing tables, filtering rules, and dozens of other such 
resources with multiple remote, independent TCP stack.  We have enough 
complexity as it is today, coordinating between the random variations of 
SMP, uniprocessor, and NUMA machines out there.  Not to mention 
competing with under-the-hood firmware actions (ASF) on NICs.

As an aside, RDMA over TCP just seems silly.  TCP was _not_ meant to do 
the things that RDMA users want.  The infiniband/RDMA programming model 
is an ultra-low-latency polling model where one or two apps are allowed 
to completely consume the machine, either busy-waiting or processing 
messages.

Unfortunately I don't have more details, so you just get a generalized 
rant :)

	Jeff



