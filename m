From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH RFC net-next] net: epoll support for busy
	poll
Date: Mon, 26 Aug 2013 00:30:45 +0300
Message-ID: <CAPcc5PhQGB195pMsMGOEE8BhZTvfXOf+Fh+3PdPbuOS0t1SULQ@mail.gmail.com>
References: <20130821103954.30607.6819.stgit@ladj378.jer.intel.com>
	<20130822201135.GA4088@dcvr.yhbt.net>
	<52170E78.1010704@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8969186734945925761=="
Cc: Willem de Bruijn <willemb@google.com>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Eilon Greenstein <eilong@broadcom.com>,
	linux-kernel@vger.kernel.org, Eric Dumazet <erdnetdev@gmail.com>,
	Eric Wong <normalperson@yhbt.net>, Eliezer Tamir <eliezer@tamir.org.il>,
	David Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <52170E78.1010704@linux.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============8969186734945925761==
Content-Type: multipart/alternative; boundary=f46d044281ea449abd04e4cc5a03

--f46d044281ea449abd04e4cc5a03
Content-Type: text/plain; charset=ISO-8859-1

I'm on vacation, will test and have some inputs later this week when I be
back.

Amir
On Aug 23, 2013 10:28 AM, "Eliezer Tamir" <eliezer.tamir@linux.intel.com>
wrote:

> On 22/08/2013 23:11, Eric Wong wrote:
> > Eliezer Tamir <eliezer.tamir@linux.intel.com> wrote:
> >> Performance:
> >> using sockperf, Intel X520 NICs,
> >> Supermicro 6026TT-BTF systems with E5-2690 Xeon CPUs
> >> 100 UDP sockets avg. latency 5.756 (std-dev 0.510)
> >> 1k  UDP sockets avg. latency 5.780 (std-dev 0.536)
> >> 10k UDP sockets avg. latency 6.269 (std-dev 0.611)
> >
> > How does this compare to with normal poll on this system?
> >
> > In other words, what advantage is there to using epoll instead of poll
> > when busy looping?
> >
> > epoll and busy_poll seem to be opposites.  epoll inherently has higher
> > latency than normal poll, but provides stable performance with many more
> > FDs.
>
> I'm not sure I understand your claim that epoll has a higher latency
> than poll.
>
> Some quick (and very unscientific) testing seem to indicate that
> while poll is slightly faster than epoll when polling one socket,
> when polling on three sockets epoll is already slightly faster.
>
> (what's the point of using poll if you only need to monitor one
> socket?)
>
> With a larger socket set epoll is a clear winner.
>
> Both select and poll on 1k UDP sockets take over 120us on a similar
> system.
> Poll on 10 sockets takes about 6.8us, on 100 socket about 16.5us.
>
> Note that I'm using a slightly old NIC that has a high HW latency.
> For comparison, a busy poll on a socket read (using netperf) is about
> 5.7us.
>
> I expect Amir is seeing better numbers, but he's not telling. ;)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--f46d044281ea449abd04e4cc5a03--


--===============8969186734945925761==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Introducing Performance Central, a new site from SourceForge and 
AppDynamics. Performance Central is your source for news, insights, 
analysis and resources for efficient Application Performance Management. 
Visit us today!
http://pubads.g.doubleclick.net/gampad/clk?id=48897511&iu=/4140/ostg.clktrk
--===============8969186734945925761==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============8969186734945925761==--
