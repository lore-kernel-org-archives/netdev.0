From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [RFC] string matching based packet classification/filtering
Date: Tue, 15 Feb 2005 22:41:47 +0100
Message-ID: <42126C9B.5060406@eurodev.net>
References: <20050215203211.GL31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
	Harald Welte <laforge@gnumonks.org>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050215203211.GL31837@postel.suug.ch>
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

Hi Thomas,

Thomas Graf wrote:

>We have been discussing string matching based packet classification and
>filterings a few times already and I'd like to make it serious this time
>to get the string matching ematch ready for 2.6.12 inclusion.
>

I agree with you. I'd like to finish see something usable. On the other 
hand, there's no need to rush anyway.

> I'm aware
>of the bayer-moore based patch by Emmanuel Roger, Gianni Tedesco, and Pablo
>but I also heard about a generic string matching architecture supporting
>various algorithms I haven't found that patchset though.
>
>Is there any effort going into the generic architecture?
>

Actually I wanted to contact Harald after this friday, once I'm done 
with my exams. I'd like to merge my work with his libqsearch hackings 
that were about to be finished.

> Any plans for
>a stateful string matching netfilter module? As it was mentioned already
>we could share some code between the ematch and netfilter.
>

Indeed, I think that we must share that code.

> I do not care
>for the algorithm, actually I think it doesn't matter at all as long as
>it's not a naive linear search.
>

An infrastructure based on libqsearch let us have different algorithms, 
so we could use whatever algorithm. This won't be a problem.

> The essential parts are to be able t define a searching range and to support paged skbs.
>

I've been working on this, I'll pass you what I have as soon as I get 
time to review it again.

> If there is someone
>going for the generic architecture fullfilling the essential parts
>just described then I'll be more than happy to use that bit of code
>otherwise I'd be happy to discuss the requirements of both sides and
>try to find a compromise both sides can live with.
>
>The requirements from my side:
> In:
>  o pattern as byte stream
>  o length of pattern
>  o begin of search range (skb layer + offset)
>  o end of search range (skb layer + offset)
>  o (p)skb
> Out:
>  o true or false
>  
>

Those look fine for me. Actually I also need more than a true of false, 
a pointer to where a matching happens. This is a requirement for 
conntrack helpers.

>Applying this on the recently posted implementation by Pablo it shows
>that it nearly fits already except for the search range. Additionaly
>it could be improved by using prefix optimizations for the fragment
>border regions instead of a naive string search which would help for
>large patterns on paged skbs.
>  
>

Sure that you can improve current way of doing things :)

>If needed an additional input argument could be added specifying the
>algorithm to be used. Eventually it requires an additional algoirthm
>specific argument carrying meta data such as prefix lookup tables.
>
>Thoughts?
>  
>

Harald,any thoughts?

--
Pablo
