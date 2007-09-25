From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [ofa-general] Re: [PATCH 1/4] [NET_SCHED] explict hold dev tx lock
Date: Tue, 25 Sep 2007 08:24:57 -0700
Message-ID: <20070925082457.6fec30d6@freepuppy.rosehill>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, kumarkr@linux.ibm.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	netdev@vger.kernel.org, rdreier@cisco.com, "Waskiewicz Jr,
	Peter P" <peter.p.waskiewicz.jr@intel.com>,
	mcarlson@broadcom.com, kaber@trash.net, randy.dunlap@oracle.com,
	jagana@us.ibm.com, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, jeff@garzik.org,
	sri@us.ibm.com, David Miller <davem@davemloft.net>
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1190726138.4264.105.camel@localhost>
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

On Tue, 25 Sep 2007 09:15:38 -0400
jamal <hadi@cyberus.ca> wrote:

> On Mon, 2007-24-09 at 17:14 -0700, Stephen Hemminger wrote:
> 
> > Since we are redoing this, 
> > is there any way to make the whole TX path
> > more lockless?  The existing model seems to be more of a monitor than
> > a real locking model.
> 

http://en.wikipedia.org/wiki/Monitor_(synchronization)
> What do you mean it is "more of a monitor"?

The transmit code path is locked as a code region, rather than just object locking
on the transmit queue or other fine grained object. This leads to moderately long
lock hold times when multiple qdisc's and classification is being done.

> 
> On the challenge of making it lockless:
> About every NAPI driver combines the tx prunning with rx polling. If you
> are dealing with tx resources on receive thread as well as tx thread,
> _you need_ locking. The only other way we can do avoid it is to separate
> the rx path interupts from ones on tx related resources; the last NAPI
> driver that did that was tulip; i think the e1000 for a short period in
> its life did the same as well. But that has been frowned on and people
> have evolved away from it.

If we went to finer grain locking it would also mean changes to all network
devices using the new locking model. My assumption is that we would use
something like the features flag to do the transition for backward compatibility.

Take this as a purely "what if" or "it would be nice if" kind of suggestion
not a requirement or some grand plan.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
