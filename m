From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 9 Oct 2007 11:22:25 -0700
Message-ID: <20071009112225.5f9756e7@freepuppy.rosehill>
References: <D5C1322C3E673F459512FB59E0DDC32903BC14AC@orsmsx414.amr.corp.intel.com>
	<1191886845.4373.138.camel@localhost> <470AD5D7.1070000@garzik.org>
	<20071008.184126.124062865.davem@davemloft.net>
	<p73k5pw44ew.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se, jeff@garzik.org,
	gaagaan@gmail.com, kaber@trash.net, netdev@vger.kernel.org,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	hadi@cyberus.ca, mcarlson@broadcom.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, sri@us.ibm.com,
	David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au
To: Andi Kleen <andi@firstfloor.org>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <p73k5pw44ew.fsf@bingen.suse.de>
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

On 09 Oct 2007 18:51:51 +0200
Andi Kleen <andi@firstfloor.org> wrote:

> David Miller <davem@davemloft.net> writes:
> > 
> > 2) Switch the default qdisc away from pfifo_fast to a new DRR fifo
> >    with load balancing using the code in #1.  I think this is kind
> >    of in the territory of what Peter said he is working on.
> 
> Hopefully that new qdisc will just use the TX rings of the hardware
> directly. They are typically large enough these days. That might avoid
> some locking in this critical path.
> 
> >    I know this is controversial, but realistically I doubt users
> >    benefit at all from the prioritization that pfifo provides.
> 
> I agree. For most interfaces the priority is probably dubious.
> Even for DSL the prioritization will be likely usually done in a router
> these days.
> 
> Also for the fast interfaces where we do TSO priority doesn't work
> very well anyways -- with large packets there is not too much 
> to prioritize.
> 
> > 3) Work on discovering a way to make the locking on transmit as
> >    localized to the current thread of execution as possible.  Things
> >    like RCU and statistic replication, techniques we use widely
> >    elsewhere in the stack, begin to come to mind.
> 
> If the data is just passed on to the hardware queue, why is any 
> locking needed at all? (except for the driver locking of course)
> 
> -Andi

I wonder about the whole idea of queueing in general at such high speeds.
Given the normal bi-modal distribution of packets, and the predominance
of 1500 byte MTU; does it make sense to even have any queueing in software
at all?


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
