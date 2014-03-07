From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH] e1000: do not allow watchdog to reenable
 transmits on shutdown
Date: Fri, 7 Mar 2014 12:14:35 -0300
Message-ID: <20140307151435.GB26026@amt.cnet>
References: <20140307020420.GA10797@amt.cnet>
	<1394162671.2214.36.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vladimir Davydov <VDavydov@parallels.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <1394162671.2214.36.camel@jtkirshe-mobl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, Mar 06, 2014 at 07:24:31PM -0800, Jeff Kirsher wrote:
> On Thu, 2014-03-06 at 23:04 -0300, Marcelo Tosatti wrote:
> > 
> > There is a race on the shutdown path of the e1000 driver
> > that allows the card to DMA into free'd memory.
> > 
> > The symptoms are similar to those described at 
> > commit d5bc77a223b0e9b9dfb002048d2b34a79e7d0b48,
> > "e1000: don't enable dma receives until after dma address has been
> > setup", where memory corruption is visible due to E1000_RXD_STAT_DD
> > being written to the DMA transfer descriptor.
> > 
> > Fix by not allowing the watchdog and tx fifo stall detector
> > to re-enable E1000_TCTL_EN.
> > 
> > Signed-off-by: Marcelo Tosatti <mtosatti@redhat.com>
> 
> Thanks I will add this to the queue.
> 
> Note- there are trailing whitespace issues and 2 comments are not
> formatted correctly.  I can fix these up if there are no other issues
> with the patch, if you want.

checkpatch.pl did not complain about those - feel free to fix them,
thanks.



------------------------------------------------------------------------------
Subversion Kills Productivity. Get off Subversion & Make the Move to Perforce.
With Perforce, you get hassle-free workflows. Merge that actually works. 
Faster operations. Version large binaries.  Built-in WAN optimization and the
freedom to use Git, Perforce or both. Make the move to Perforce.
http://pubads.g.doubleclick.net/gampad/clk?id=122218951&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
