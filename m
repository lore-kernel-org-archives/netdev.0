From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC PATCH 0/5] net: low latency Ethernet device
	polling
Date: Mon, 04 Mar 2013 15:37:56 +0800
Message-ID: <51344F54.8060809@gmail.com>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
	HPA <hpa@zytor.com>, Eliezer Tamir <eliezer@tamir.org.il>,
	Dave Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 02/28/2013 01:55 AM, Eliezer Tamir wrote:
>
> Open issues:
> 1. Find a way to avoid the need to change the sk and skb structs.
> One big disadvantage of how we do this right now is that when a device is
> removed, it's hard to prevent it from getting polled by a socket
> which holds a stale reference.
>
> 2. How do we decide which sockets are eligible to do busy polling?
> Do we add a socket option to control this?
> How do we provide sane defaults while allowing flexibility and performance?
>
> 3. Andi Kleen and HPA pointed out that using get_cycles() is not portable.
>
> 4. How and where do we call ndo_ll_poll from the socket code?
> One good place seems to be wherever the kernel puts the process to sleep,
> waiting for more data, but this makes doing something intelligent about
> poll (the system call) hard. From the perspective of how ndo_ll_poll
> itself is implemented this does not seem to matter.
>
> 5. I would like to hear suggestions on naming conventions and where
> to put the code that for now I have put in include/net/ll_poll.h
>


A dumb question: is bypassing tcpdump/netfilters/qdisc etc. what we 
always want? Isn't this a security issue?

Thanks!

------------------------------------------------------------------------------
Everyone hates slow websites. So do we.
Make your web apps faster with AppDynamics
Download AppDynamics Lite for free today:
http://p.sf.net/sfu/appdyn_d2d_feb
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
