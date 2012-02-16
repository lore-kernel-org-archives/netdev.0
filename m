From: Ben Greear <greearb@candelatech.com>
Subject: rx-over-length stats problem with e100
Date: Wed, 15 Feb 2012 16:57:53 -0800
Message-ID: <4F3C5491.7090600@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	e1000-devel list <e1000-devel@lists.sourceforge.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

While testing my rx-all patches, I triggered a code branch
that caused the rx_over_length_errors counter to increment
in the e100_rx_indicate path (it can already increment there
w/out my patch, it appears).

The problem is that then the stats go weird because the code in
e100_update_stats adds the total rx_over_length_errors each time
it's called, and does not reset the rx_over_length_errors to zero:

		ns->rx_length_errors += le32_to_cpu(s->rx_short_frame_errors) +
			nic->rx_over_length_errors;


So, should we zero out that counter after reading it (although that
might race)?  Any idea how this is supposed to work?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


------------------------------------------------------------------------------
Virtualization & Cloud Management Using Capacity Planning
Cloud computing makes use of virtualization - but cloud computing 
also focuses on allowing computing to be delivered as a service.
http://www.accelacomm.com/jaw/sfnl/114/51521223/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
