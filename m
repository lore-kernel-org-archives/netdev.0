From: Jeff Garzik <jeff@garzik.org>
Subject: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Mon, 08 Oct 2007 22:12:03 -0400
Message-ID: <470AE373.9020207@garzik.org>
References: <D5C1322C3E673F459512FB59E0DDC32903BC14AC@orsmsx414.amr.corp.intel.com>	<1191886845.4373.138.camel@localhost>	<470AD5D7.1070000@garzik.org>
	<20071008.184126.124062865.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	hadi@cyberus.ca, mcarlson@broadcom.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, sri@us.ibm.com,
	shemminger@linux-foundation.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20071008.184126.124062865.davem@davemloft.net>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> 1) A library for transmit load balancing functions, with an interface
>    that can be made visible to userspace.  I can write this and test
>    it on real multiqueue hardware.
> 
>    The whole purpose of this library is to set skb->queue_mapping
>    based upon the load balancing function.
> 
>    Facilities will be added to handle virtualization port selection
>    based upon destination MAC address as one of the "load balancing"
>    methods.

Groovy.

I'm interested in working on a load balancer function that approximates

	skb->queue_mapping = smp_processor_id()

I'd be happy to code and test in that direction, based on your lib.


> 2) Switch the default qdisc away from pfifo_fast to a new DRR fifo
>    with load balancing using the code in #1.  I think this is kind
>    of in the territory of what Peter said he is working on.
> 
>    I know this is controversial, but realistically I doubt users
>    benefit at all from the prioritization that pfifo provides.  They
>    will, on the other hand, benefit from TX queue load balancing on
>    fast interfaces.

IMO the net driver really should provide a hint as to what it wants.

8139cp and tg3 would probably prefer multiple TX queue behavior to match 
silicon behavior -- strict prio.

And I'll volunteer to write the net driver code for that, if people want 
to see how things would look for that type of hardware packet scheduling.


> 3) Work on discovering a way to make the locking on transmit as
>    localized to the current thread of execution as possible.  Things
>    like RCU and statistic replication, techniques we use widely
>    elsewhere in the stack, begin to come to mind.

Definitely.

	Jeff
