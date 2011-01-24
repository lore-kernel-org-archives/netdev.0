From: Rick Jones <rick.jones2@hp.com>
Subject: Re: does intel X520-SR(ixgbe) support RSS on single
	VLAN?
Date: Mon, 24 Jan 2011 10:10:43 -0800
Message-ID: <4D3DC0A3.8080503@hp.com>
References: <AANLkTinuozfPcAZStV-a=siqcLesqPHnGhVh=QitOnQs@mail.gmail.com>
	<4D3DB248.5070802@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Rui <wirelesser@gmail.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4D3DB248.5070802@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Alexander Duyck wrote:
> I would recommend testing with something like the "netperf -t TCP_CRR" 
> test which should open a number of ports and spread traffic out between 
> multiple queues.

TCP_CRR - Connect Request Response - it will cycle through almost the entire 
port space as it goes, one at a time.  Any one four-tuple will be unlikely to 
have all that many packets - just the SYN exchange, the request/response 
exchange and then the FIN exchange, so unless there is a tool looking at the 
queues with microsecond granularity, it will appear like it is all happening at 
once :)

If you want to see one queue used for "a while" and then another, I would 
suggest a TCP_RR test with the confidence intervals set to say 30 iterations. 
That will exchange packets for the test duration (global -l option) and then the 
next iteration will have a four-tuple that differs in the client port number 
from the previous (the "server" port number remains fixed through the iterations 
of the TCP_RR test.

One can also run TCP_RR tests in turn, one after the other, but that consumes 
port numbers in twos on both sides.  I suppose that these days with port number 
randomization that's OK, but in "the old days" it tended to mean that the 
control and data ports marched in lock-step and one would always be even the 
other odd, which didn't always work that well with hashes...  The use of the 
confidence intervals with the TCP_RR test deals with that by having only the one 
netperf control connection and then successive data connections.

happy benchmarking,

rick jones

There is also always the full specification of the port numbers and IP's for the 
data connection, though it is a bit more cumbersome.

------------------------------------------------------------------------------
Special Offer-- Download ArcSight Logger for FREE (a $49 USD value)!
Finally, a world-class log management solution at an even better price-free!
Download using promo code Free_Logger_4_Dev2Dev. Offer expires 
February 28th, so secure your free ArcSight Logger TODAY! 
http://p.sf.net/sfu/arcsight-sfd2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
