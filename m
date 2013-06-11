From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v10 net-next 0/6] net: low latency
 Ethernet device polling
Date: Tue, 11 Jun 2013 00:32:44 -0700
Message-ID: <1370935964.3252.24.camel@edumazet-glaptop>
References: <20130610083929.6955.87206.stgit@ladj378.jer.intel.com>
	<20130610.134116.1913599114372510768.davem@davemloft.net>
	<51B68AA6.1050105@linux.intel.com>
	<20130610.212443.1096102996038709384.davem@davemloft.net>
	<51B6C87B.70101@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, or.gerlitz@gmail.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, hpa@zytor.com, amirv@mellanox.com,
	jesse.brandeburg@intel.com, eliezer@tamir.org.il,
	linux-kernel@vger.kernel.org, andi@firstfloor.org,
	bhutchings@solarflare.com, eilong@broadcom.com,
	David Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <51B6C87B.70101@linux.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 2013-06-11 at 09:49 +0300, Eliezer Tamir wrote:

> I would like to hear opinions on what needs to be added to make this
> feature complete.
> 
> The list I have so far is:
> 1. add a socket option

Yes, please. I do not believe all sockets on the machine are candidate
for low latency. In fact very few of them should be, depending on the
number of cpu and/or RX queues.

> 2. support for poll/select

As long as the cost of llpoll is bounded per poll()/select() call it
will be ok.

> 3. support for epoll

For this one, I honestly do not know how to proceed.

epoll Edge Trigger model is driven by the wakeups events.

The wakeups come from frames being delivered by the NIC (for UDP/TCP
sockets)

If epoll_wait() has to scan the list of epitem to be able to perform the
llpoll callback, it will be too slow : We come back to poll() model,
with O(N) execution time.

Ideally we would have to callback llpoll not from the tcp_poll(), but
right before putting current thread in wait mode.

> 
> Also, would you accept a trailing whitespace cleanup patch for
> fs/select.c?

This has to be submitted to lkml




------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
