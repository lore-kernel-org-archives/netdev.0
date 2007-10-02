From: Bill Fink <billfink@mindspring.com>
Subject: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 2 Oct 2007 00:25:02 -0400
Message-ID: <20071002002502.fe0f2bb3.billfink@mindspring.com>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070916.161748.48388692.davem@davemloft.net>
	<1189988958.4230.55.camel@localhost>
	<1190569987.4256.52.camel@localhost>
	<1190570205.4256.56.camel@localhost>
	<1190570317.4256.59.camel@localhost>
	<1190570409.4256.62.camel@localhost>
	<1191178346.6165.29.camel@localhost>
	<20071001001135.75d2b984.billfink@mindspring.com>
	<1191245440.4378.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, Robert.Olsson@data.slu.se, gaagaan@gmail.com,
	kumarkr@linux.ibm.com, peter.p.waskiewicz.jr@intel.com,
	shemminger@linux-foundation.org, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, jeff@garzik.org, rdreier@cisco.com,
	mcarlson@broadcom.com, general@lists.openfabrics.org,
	sri@us.ibm.com, jagana@us.ibm.com, mchan@broadcom.com,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	tgraf@suug.ch, kaber@trash.net
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1191245440.4378.12.camel@localhost>
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

On Mon, 01 Oct 2007, jamal wrote:

> On Mon, 2007-01-10 at 00:11 -0400, Bill Fink wrote:
> 
> > Have you done performance comparisons for the case of using 9000-byte
> > jumbo frames?
> 
> I havent, but will try if any of the gige cards i have support it.
> 
> As a side note: I have not seen any useful gains or losses as the packet
> size approaches even 1500B MTU. For example, post about 256B neither the
> batching nor the non-batching give much difference in either throughput
> or cpu use. Below 256B, theres a noticeable gain for batching.
> Note, in the cases of my tests all 4 CPUs are in full-throttle UDP and
> so the occupancy of both the qdisc queue(s) and ethernet ring is
> constantly high. For example at 512B, the app is 80% idle on all 4 CPUs
> and we are hitting in the range of wire speed. We are at 90% idle at
> 1024B. This is the case with or without batching.  So my suspicion is
> that with that trend a 9000B packet will just follow the same pattern.

One reason I ask, is that on an earlier set of alternative batching
xmit patches by Krishna Kumar, his performance testing showed a 30 %
performance hit for TCP for a single process and a size of 4 KB, and
a performance hit of 5 % for a single process and a size of 16 KB
(a size of 8 KB wasn't tested).  Unfortunately I was too busy at the
time to inquire further about it, but it would be a major potential
concern for me in my 10-GigE network testing with 9000-byte jumbo
frames.  Of course the single process and 4 KB or larger size was
the only case that showed a significant performance hit in Krishna
Kumar's latest reported test results, so it might be acceptable to
just have a switch to disable the batching feature for that specific
usage scenario.  So it would be useful to know if your xmit batching
changes would have similar issues.

Also for your xmit batching changes, I think it would be good to see
performance comparisons for TCP and IP forwarding in addition to your
UDP pktgen tests, including various packet sizes up to and including
9000-byte jumbo frames.

						-Bill
