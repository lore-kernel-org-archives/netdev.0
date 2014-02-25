From: David Laight <David.Laight@ACULAB.COM>
Subject: Re: [PATCH 0/2] ixgbe, fix numa issues
Date: Tue, 25 Feb 2014 10:21:34 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6CA75F@AcuExch.aculab.com>
References: <1393267913-28212-1-git-send-email-prarit@redhat.com>
	<530B9C3E.1000308@intel.com> <530B9EC9.4080007@redhat.com>
	<530BA40E.3060008@intel.com> <530BEC90.2010705@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "nhorman@redhat.com" <nhorman@redhat.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"agospoda@redhat.com" <agospoda@redhat.com>,
	John Ronciak <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: 'Prarit Bhargava' <prarit@redhat.com>, Alexander Duyck
	<alexander.h.duyck@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <530BEC90.2010705@redhat.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Prarit Bhargava
...
> What has caused that check to be necessary is that the ixgbe driver is now
> allocating so many interrupts that on large systems which full sockets are taken
> in and out of service, it is possible that there are not enough empty vectors
> for all the irqs on a down'd cpu.  IMO what the ixgbe driver is effectively
> doing is starving the system of resources.  If I rmmod the ixgbe driver (and
> free it's irqs of course) I have no problem in taking all cpus except 1 out of
> service.

If I read that correctly it looks as though ixgbe should be allocating
a number of interrupts on each cpu - for the interrupts it wants to take
on that cpu.

Then taking the cpu out of service would 'just' require that the interrupts
that are tied to that cpu be removed first?

	David




------------------------------------------------------------------------------
Flow-based real-time traffic analytics software. Cisco certified tool.
Monitor traffic, SLAs, QoS, Medianet, WAAS etc. with NetFlow Analyzer
Customize your own dashboards, set traffic alerts and generate reports.
Network behavioral analysis & security monitoring. All-in-one tool.
http://pubads.g.doubleclick.net/gampad/clk?id=126839071&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
