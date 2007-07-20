From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [ofa-general] Re: [PATCH 00/10] Implement batching skb API
Date: Fri, 20 Jul 2007 08:18:48 +0100
Message-ID: <20070720081848.7cc652fb@oldman>
References: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jagana@us.ibm.com, kaber@trash.net, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, sri@us.ibm.com, hadi@cyberus.ca,
	davem@davemloft.net
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
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

On Fri, 20 Jul 2007 12:01:49 +0530
Krishna Kumar <krkumar2@in.ibm.com> wrote:

> Hi Dave, Roland, everyone,
> 
> In May, I had proposed creating an API for sending 'n' skbs to a driver to
> reduce lock overhead, DMA operations, and specific to drivers that have
> completion notification like IPoIB - reduce completion handling ("[RFC] New
> driver API to speed up small packets xmits" @
> http://marc.info/?l=linux-netdev&m=117880900818960&w=2). I had also sent
> initial test results for E1000 which showed minor improvements (but also
> got degradations) @http://marc.info/?l=linux-netdev&m=117887698405795&w=2.
> 
> After fine-tuning qdisc and other changes, I modified IPoIB to use this API,
> and now get good gains. Summary for TCP & No Delay: 1 process improves for
> all cases from 1.4% to 49.5%; 4 process has almost identical improvements
> from -1.7% to 59.1%; 16 process case also improves in the range of -1.2% to
> 33.4%; while 64 process doesn't have much improvement (-3.3% to 12.4%). UDP
> was tested with 1 process netperf with small increase in BW but big
> improvement in Service Demand. Netperf latency tests show small drop in
> transaction rate (results in separate attachment).
> 

You may see worse performance with batching in the real world when
running over WAN's.  Like TSO, batching will generate back to back packet
trains that are subject to multi-packet synchronized loss. The problem is that
intermediate router queues are often close to full, and when a long string
of packets arrives back to back only the first ones will get in, the rest
get dropped.  Normal sends have at least minimal pacing so they are less
likely do get synchronized drop.
