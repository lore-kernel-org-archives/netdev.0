From: =?ISO-8859-1?Q?Andreas_Bofj=E4ll?= <andreas.bofjall@ericsson.com>
Subject: Re: [PATCH net-next 1/5] tipc: silence sparse
	warnings
Date: Fri, 27 Sep 2013 10:15:09 +0200
Message-ID: <52453E8D.2020705@ericsson.com>
References: <1380014868-2797-1-git-send-email-jon.maloy@ericsson.com>
	<1380014868-2797-2-git-send-email-jon.maloy@ericsson.com>
	<20130927.015908.1293107524454870319.davem@davemloft.net>
	<52453B51.5070702@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, David Miller <davem@davemloft.net>
To: Ying Xue <ying.xue@windriver.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <52453B51.5070702@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 09/27/2013 10:01 AM, Ying Xue wrote:
> Good point!
> It's better for us to use memcpy_fromiovecend() instead of
> skb_copy_to_linear_data() and its friends.
>
> We will submit another version to correct this error soon.

I could be wrong here, but I think you should also remove the entire 
cast on line 1210 in link.c:

sect_crs = msg_sect[curr_sect].iov_base;

There should be no reason to cast there since you made sect_crs into 
const unchar* __user and msg_sect[].iov_base is void* __user.

/Andreas

------------------------------------------------------------------------------
October Webinars: Code for Performance
Free Intel webinars can help you accelerate application performance.
Explore tips for MPI, OpenMP, advanced profiling, and more. Get the most from 
the latest Intel processors and coprocessors. See abstracts and register >
http://pubads.g.doubleclick.net/gampad/clk?id=60133471&iu=/4140/ostg.clktrk
