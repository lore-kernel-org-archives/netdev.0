From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: e1000: eth2: e1000_clean_tx_irq: Detected Tx Unit Hang
Date: Mon, 6 Apr 2009 10:36:06 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.0904061029410.5196@jbrandeb-desk1.amr.corp.intel.com>
References: <49D867BE.1010700@krogh.cc>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	jesse.brandeburg@intel.com, e1000-devel@lists.sourceforge.net
To: Jesper Krogh <jesper@krogh.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15673 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750903AbZDFRgJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Apr 2009 13:36:09 -0400
In-Reply-To: <49D867BE.1010700@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Jesper,

On Sun, 5 Apr 2009, Jesper Krogh wrote:
> I have a 2.6.27.20 system in production, the e1000 drivers seem pretty 
> "noisy" allthough everything appears to work excellent.

well, nice to hear its working, but wierd about the messages.
 
> dmesg here: http://krogh.cc/~jesper/dmesg-ko-2.6.27.20.txt
> 
> [476197.380486] e1000: eth3: e1000_clean_tx_irq: Detected Tx Unit Hang
> [476197.380488]   Tx Queue             <0>
> [476197.380489]   TDH                  <c>
> [476197.380490]   TDT                  <63>
> [476197.380490]   next_to_use          <63>
> [476197.380491]   next_to_clean        <b>
> [476197.380491] buffer_info[next_to_clean]
> [476197.380492]   time_stamp           <10717579a>
> [476197.380492]   next_to_watch        <f>
> [476197.380493]   jiffies              <107175a3e>
> [476197.380494]   next_to_watch.status <0>
> 
> The system has been up for 14 days but the dmesg-buffer has allready 
> overflown with these.

I looked at your dmesg and it appears that there is never a 
NETDEV_WATCHDOG message, which would normally indicate that the driver 
isn't resetting itself out of the problem.  Does ethtool -S eth3 show any 
tx_timeout_count ?
 
> Configuratoin is a 4 x 1GbitE bond all with Intel NICs
> 
> 06:01.0 Ethernet controller: Intel Corporation 82546EB Gigabit Ethernet 
> Controller (Copper) (rev 03)
> 06:01.1 Ethernet controller: Intel Corporation 82546EB Gigabit Ethernet 
> Controller (Copper) (rev 03)
> 06:02.0 Ethernet controller: Intel Corporation 82546EB Gigabit Ethernet 
> Controller (Copper) (rev 03)
> 06:02.1 Ethernet controller: Intel Corporation 82546EB Gigabit Ethernet 
> Controller (Copper) (rev 03)

are you doing testing with the remote end of this link?  I'm wondering if 
something changed in the kernel that is causing remote link down events to 
not stop the tx queue (our hardware just completely stops in its tracks 
w.r.t tx when link goes down)
