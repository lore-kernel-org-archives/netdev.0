From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] Re: [PATCH 1/4] [NET_SCHED] explict hold dev tx lock
Date: Tue, 25 Sep 2007 18:14:51 -0400
Message-ID: <1190758491.4244.15.camel@localhost>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070916.161748.48388692.davem@davemloft.net>
	<1189988958.4230.55.camel@localhost>
	<1190569987.4256.52.camel@localhost>
	<1190570205.4256.56.camel@localhost>
	<D5C1322C3E673F459512FB59E0DDC32903A51122@orsmsx414.amr.corp.intel.com>
	<1190674298.4264.24.camel@localhost>
	<D5C1322C3E673F459512FB59E0DDC32903A51462@orsmsx414.amr.corp.intel.com>
	<1190677099.4264.37.camel@localhost>
	<D5C1322C3E673F459512FB59E0DDC32903A5151B@orsmsx414.amr.corp.intel.com>
	<20070924171411.36494656@freepuppy.rosehill>
	<1190726138.4264.105.camel@localhost>
	<20070925082457.6fec30d6@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, kumarkr@linux.ibm.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	netdev@vger.kernel.org, rdreier@cisco.com, "Waskiewicz Jr,
	Peter P" <peter.p.waskiewicz.jr@intel.com>,
	mcarlson@broadcom.com, kaber@trash.net, randy.dunlap@oracle.com,
	jagana@us.ibm.com, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, jeff@garzik.org,
	sri@us.ibm.com, David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070925082457.6fec30d6@freepuppy.rosehill>
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

On Tue, 2007-25-09 at 08:24 -0700, Stephen Hemminger wrote:

> The transmit code path is locked as a code region, rather than just object locking
> on the transmit queue or other fine grained object. This leads to moderately long
> lock hold times when multiple qdisc's and classification is being done.

It will be pretty tricky to optimize that path given the dependencies
between the queues, classifiers, and actions in enqueues; schedulers in
dequeues as well as their config/queries from user space which could
happen concurently on all "N" CPUs. 
The txlock optimization i added in patch1 intends to let go of the queue
lock when we enter the dequeue region sooner to reduce the contention.

A further optimization i made was to reduce the time it takes to hold
the tx lock at the driver by moving gunk that doesnt need lock-holding
into the new method dev->hard_end_xmit() (refer to patch #2)

> If we went to finer grain locking it would also mean changes to all network
> devices using the new locking model. My assumption is that we would use
> something like the features flag to do the transition for backward compatibility.
> Take this as a purely "what if" or "it would be nice if" kind of suggestion
> not a requirement or some grand plan.

Ok, hopefully someone would demonstrate how to achieve it; seems a hard
thing to achieve.

cheers,
jamal
