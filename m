From: Donald Becker <becker@scyld.com>
Subject: Re: Hot-plug for pcnet32 ?
Date: Mon, 19 Jan 2004 12:29:59 -0500 (EST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0401191216290.8974-100000@beohost>
References: <200401191614.i0JGE9p10337@dyn318364bld.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-net@vger.kernel.org, <netdev@oss.sgi.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: Don Fry <brazilnut@us.ibm.com>
In-Reply-To: <200401191614.i0JGE9p10337@dyn318364bld.beaverton.ibm.com>
List-Id: netdev.vger.kernel.org

On Mon, 19 Jan 2004, Don Fry wrote:
> > > Any chance that anyone is thinking of adding hot-plug support
> > > to the pcnet32 driver? 
> Here is a repeat of a patch to enable PCI Hot Plug for pcnet32.

Errrmmm, you need to much more than that!

Here are a few rules for writing hotremove-safe drivers:

   Don't count on "remove interrupts": hardware may disappear at any time.
   Always check for 0xffffffff when starting a new hardware operation.
   This may usually be done very efficiently: in an interrupt handler
   check for all error status bits with a mask, and in the error
   handling routine check for missing hardware.

   Analyze the transmit routine routine.  In many cases the driver can
   "just assume everything will according to plan and leave the room".
   But if the driver reads from the hardware, it presumably depends on
   the value and should check for missing hardware.

   Don't forget statistics and ioctl() routines when checking for
   missing hardware.

   Never have unlimited loops.  Always use an explicit loop limit
   (e.g. 'boguscnt=1000' or 'work_limit=20') rather than rely on the
   value in a hardware register changing.


-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
914 Bay Ridge Road, Suite 220		Scyld Beowulf cluster systems
Annapolis MD 21403			410-990-9993

