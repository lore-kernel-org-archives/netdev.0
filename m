From: Joe Perches <joe@perches.com>
Subject: Re: Strange latency spikes/TX network stalls on Sun
 Fire X4150(x86) and e1000e
Date: Wed, 30 May 2012 07:09:33 -0700
Message-ID: <1338386973.32113.23.camel@joe2Laptop>
References: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>
	<88c43001441945e1431609db252b69e7@visp.net.lb>
	<df211722d18136698aeeda2f17b876e2@visp.net.lb>
	<d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>
	<CA+mtBx9axFKCjLwDYMvXXP2nB_og896kAhG0UYWaK6PTAXhPcw@mail.gmail.com>
	<79d6b56fdf5f4be4656079568d5a7445@visp.net.lb>
	<CA+mtBx_sF5GCMRpLQuTruZ=xpFTFpd5z8SZJaG_dBqf4oCXpwg@mail.gmail.com>
	<20120529232518.e5b41759.shimoda.hiroaki@gmail.com>
	<CA+mtBx_uYy9XcRvpD2E46FuMBFu38iQvCiwFHWqbhPBmY=JfOg@mail.gmail.com>
	<20120530090602.6204d857.shimoda.hiroaki@gmail.com>
	<1338367231.2760.125.camel@edumazet-glaptop>
	<20120530194355.92bf5d51.shimoda.hiroaki@gmail.com>
	<1338376107.2760.156.camel@edumazet-glaptop>
	<1338376817.32113.5.camel@joe2Laptop>
	<1338379151.2760.166.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	davem@davemloft.net, Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1338379151.2760.166.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 2012-05-30 at 13:59 +0200, Eric Dumazet wrote:
> On Wed, 2012-05-30 at 04:20 -0700, Joe Perches wrote:
> > On Wed, 2012-05-30 at 13:08 +0200, Eric Dumazet wrote:
> > > Maybe we should change all POSDIFF(), not selected ones.
> > > #define POSDIFF(A, B) ((int)((A) - (B)) > 0 ? (A) - (B) : 0)
> > 
> > maybe use an eval once statement expression macro
> > ({
> > 	typeof (A) _a = (A);
> > 	typeof (B) _b = (B);
> > 	((int)(_a - _b) > 0 ? _a - _b : 0;
> > })
> 
> Well, many choices are possible, including
> #define POSDIFF(A, B) max_t(int, (A) - (B), 0);

Maybe. If the intent to always return an int.
The current macro doesn't.

Whatever evals A and B once would be better.

cheers, Joe


------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
