From: jamal <hadi@cyberus.ca>
Subject: Re: Billing 3: WAS(Re: [PATCH 2/4] deferred drop, __parent
	workaround, reshape_fail , netdev@oss.sgi.com ,
Date: 25 Aug 2004 07:50:51 -0400
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <1093434651.1039.182.camel@jzny.localdomain>
References: <411C0FCE.9060906@crocetta.org>
	<1092401484.1043.30.camel@jzny.localdomain>
	<20040816072032.GH15418@sunbeam2>
	<1092661235.2874.71.camel@jzny.localdomain>
	<4120D068.2040608@crocetta.org>
	<1092743526.1038.47.camel@jzny.localdomain>
	<41220AEA.20409@crocetta.org>
	<1093191124.1043.206.camel@jzny.localdomain>
	<20040824184636.GO26877@sunbeam.de.gnumonks.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: sandr8 <sandr8_NOSPAM_@crocetta.org>, devik@cdi.cz,
	netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040824184636.GO26877@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Tue, 2004-08-24 at 14:46, Harald Welte wrote:
> On Sun, Aug 22, 2004 at 12:12:04PM -0400, jamal wrote:

> > Such packets are cloned or copied. I am going to assume the contrack
> > data remains intact in both cases. LaForge?
> 
> Yes. But still it is a question of viewpoint what kind of behaviour is
> correct.  Let's say a single packet is accounted in ct_acct, and then
> sent to multiple interfaces, where on more than one of them it gets
> unbilled.  So we add once, but 'unbill' (i prefer the term subtract)
> more than once.   In the end the ct_acct counter will be less than when
> it first encountered the packet.
> 

These are some of the challenges i posed to Allesandro as well.

> > In the future we should make accounting a feature that could be turned
> > on despite contracking and skbs should carry an accounting metadata with
> > them. 
> 
> I don't really understand what you want to say.  You want accounting
> that is not conntrack-based?  well, then you should maybe look at
> one of the many methods, ranging from iptables rule counters to the 
> ipt_acct match/target, nacctd, pcap-mmap, PF_RING, ULOG-based, ...
> 

The discussion with fairness lead to my assertion above.
None of the above take care of fairness factor that Alessandro is trying
to achieve. So my thinking is if we wanna fix the unbill problem, why
not address the whole issue and get accounting to be an embedded piece.

> btw, they all account the amount of RX packet on inbound interface and
> do not 'unbill' ;)

I suspect in such a case you have a passive box which just gets a copy
of the packet from the wire ;-> Someone else in the real box where the
packet gets forwarded will drop the packet and it will still be paid 
for ;->
In the case of what you have introduced though, you are billing for
localy generated packets as well (if i am not mistaken this is where the
issues are).

In general i dont think we need to be 100% accurate. PSAMP for example
operates by merely sampling i.e not taking a precise measurement. People
have written tons of papers to prove it was good enuf.

cheers,
jamal
