From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] e1000: Don't enable polling in open()
	(was: e1000: assertion hit in e1000_clean(), kernel 2.6.21.1)
Date: Mon, 21 May 2007 21:22:27 -0400
Message-ID: <20070522012227.GD11401@redhat.com>
References: <20070521215134.14885.84952.stgit@localhost.localdomain>
	<20070521221635.GA16888@redhat.com>
	<20070522004921.GA8130@gondor.apana.org.au>
	<46524033.4030901@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, e1000-devel@lists.sourceforge.net,
	Herbert Xu <herbert.xu@redhat.com>, greg@suse.de,
	stable@vger.kernel.org, netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <46524033.4030901@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, May 21, 2007 at 05:58:27PM -0700, Kok, Auke wrote:
 > >> This probably doesn't solve the latter bug.
 > >> The code you reference isn't there in the kernel tested in that bug
 > >> (2.6.21)   In 2.6.21, netif_poll_enable is only called from
 > >> e1000_up(), not e1000_open()
 > > 
 > > Yes we need a different fix for 2.6.21.  There e1000_open calls
 > > e1000_up which is why we still get the netif_poll_enable.
 > 
 > yes, basically they need the patch that introduced(exposed) the problem as well, 
 > but that is a rather significant change and kind of moves the whole 
 > netstack-init code in e1000 around. The size was the reason why that patch 
 > didn't go into 2.6.21 in the first place, but perhaps they can pull both patches 
 > into the FC tree.
 > 
 > For reference, this is the commit:
 > 
 > commit e0aac5a289b1dacbc94bd9ae8c449bcdf9ab508c
 > Author: Auke Kok <auke-jan.h.kok@intel.com>
 > Date:   Tue Mar 6 08:57:21 2007 -0800
 > 
 >      e1000: FIX: be ready for incoming irq at pci_request_irq
 > 
 >      DEBUG_SHIRQ code exposed that e1000 was not ready for incoming interrupts
 >      after having called pci_request_irq. This obviously requires us to finish
 >      our software setup which assigns the irq handler before we request the
 >      irq.
 > 
 >      Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
 >      Signed-off-by: Jeff Garzik <jeff@garzik.org>
 > 
 > Dave, would that be an option for you?

Sounds like a plan.  I'll do a test-build with this and the other
patch, and throw it at the people seeing the problem tomorrow.

Thanks,

	Dave

-- 
http://www.codemonkey.org.uk

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
