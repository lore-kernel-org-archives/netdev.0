From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC] string matching based packet classification/filtering
Date: Tue, 15 Feb 2005 21:32:11 +0100
Message-ID: <20050215203211.GL31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
To: Pablo Neira <pablo@eurodev.net>,
	Harald Welte <laforge@gnumonks.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

We have been discussing string matching based packet classification and
filterings a few times already and I'd like to make it serious this time
to get the string matching ematch ready for 2.6.12 inclusion. I'm aware
of the bayer-moore based patch by Emmanuel Roger, Gianni Tedesco, and Pablo
but I also heard about a generic string matching architecture supporting
various algorithms I haven't found that patchset though.

Is there any effort going into the generic architecture? Any plans for
a stateful string matching netfilter module? As it was mentioned already
we could share some code between the ematch and netfilter. I do not care
for the algorithm, actually I think it doesn't matter at all as long as
it's not a naive linear search. The essential parts are to be able to
define a searching range and to support paged skbs. If there is someone
going for the generic architecture fullfilling the essential parts
just described then I'll be more than happy to use that bit of code
otherwise I'd be happy to discuss the requirements of both sides and
try to find a compromise both sides can live with.

The requirements from my side:
 In:
  o pattern as byte stream
  o length of pattern
  o begin of search range (skb layer + offset)
  o end of search range (skb layer + offset)
  o (p)skb
 Out:
  o true or false

Applying this on the recently posted implementation by Pablo it shows
that it nearly fits already except for the search range. Additionaly
it could be improved by using prefix optimizations for the fragment
border regions instead of a naive string search which would help for
large patterns on paged skbs.

If needed an additional input argument could be added specifying the
algorithm to be used. Eventually it requires an additional algoirthm
specific argument carrying meta data such as prefix lookup tables.

Thoughts?
