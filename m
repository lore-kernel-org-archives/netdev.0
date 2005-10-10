From: Grant Grundler <iod00d@hp.com>
Subject: Re: Timeline of IPoIB performance
Date: Mon, 10 Oct 2005 14:26:52 -0700
Message-ID: <20051010212652.GG9613@esmail.cup.hp.com>
References: <1128672413.13948.326.camel@localhost> <52br20lsei.fsf@cisco.com>
	<1128738350.13945.369.camel@localhost> <521x2tgrim.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <rolandd@cisco.com>
Content-Disposition: inline
In-Reply-To: <521x2tgrim.fsf@cisco.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 10, 2005 at 11:23:45AM -0700, Roland Dreier wrote:
>      > 2.6.12-rc5      in-kernel    1     405   <<<<<
>      > 2.6.12-rc4      in-kernel    1     470   <<<<<
> 
> I was optimistic when I saw this, because the changeover to git
> occurred with 2.6.12-rc2, so I thought I could use git bisect to track
> down exactly when the performance regression happened.
> 
> However, I haven't been able to get numbers that are stable enough to
> track this down.  I have two systems, both HP DL145s with dual Opteron
> 875s and two-port mem-free PCI Express HCAs.  I use MSI-X with the
> completion interrupt affinity set to CPU 0, and "taskset 2" to run
> netserver and netperf on CPU 1.

As you know, opteron boxes are NUMA. I think you want MSI-X interrupt
bound to the same CPU that's connected to the IO. Is CPU 0 closer to IO?
I would bind netperf to CPU0 and netserver to CPU 1 on each box respectively.
Or just try all 4 combinations to see which combinations are CPU bound
vs memory/IO bound.

> With default netperf parameters (just "-H otherguy") I get numbers
> between ~490 MB/sec and ~550 MB/sec for 2.6.12-rc4 and 2.6.12-rc5.
> The numbers are quite consistent between reboots, but if I reboot the
> system (even keeping the kernel identical), I see large performance
> changes.

I gather you meant "tests" in the first phrase? (vs reboot).

> Presumably something is happening like the cache coloring of
> some hot data structures changing semi-randomly depending on the
> timing of various initialations.

My guess is based on the same premise.
The mem-free card will be very sensitive to were it's control data
is allocated. Is either box configured to interleave memory from
both CPUs?

If it's interleaving, every other cacheline will be "local".
Can you disable interleave and try different netperf/server
bindings as suggested above?

hth,
grant
