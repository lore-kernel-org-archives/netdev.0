From: Christoph Hellwig <hch@infradead.org>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Sat, 30 Jun 2007 09:25:20 +0100
Message-ID: <20070630082520.GA20140@infradead.org>
References: <1183138159.17243.16.camel@blaa>
	<20070629175006.GB3917@falooley.org>
	<468571C6.3090305@garzik.org> <46857C08.4030303@intel.com>
	<20070629150350.414553d4.akpm@linux-foundation.org>
	<4685838D.9080108@garzik.org>
	<c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>
	<46859F3F.305@garzik.org> <4685C09B.7040908@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	Jeff Garzik <jeff@garzik.org>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Andrew Grover <andy.grover@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <4685C09B.7040908@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, Jun 29, 2007 at 07:31:55PM -0700, Kok, Auke wrote:
> all the pci-express adapters that are supported are extremely similar:
> 
> - they all support 2 queues
> - the register sets are (almost entirely) identical
> - there is minimal feature variance between 82571/2/3, esb2lan, ich8/9
> 
> The major differences between 82571/2/3, esb2lan and ich8/9 are PHY-based 
> (4 different PHY's basically, one for 82571/2/3, one for esb2lan and 2 for 
> ich8/9, excluding fiber and serdes here) and NVM/EEPROM.
> 
> 
> ich8 and 9 are consistent with 82571/2/3 - on-board nic's based on the 
> 82571 design with different PHY's, and added features for the newer 
> demands. A driver split here would be possible but not justified IMHO.

Sounds like the perfect split to me.  I'd suggest you rip out support
for older hardware from your new driver and do the resulting simplification
and post a new e1000e driver for this hardware, removing existing support
from e1000 at the same time.  Later you can do the feature flags and similar
improvements to the old driver driver in an incremental fashion without the
burden of having to keep up with new hardware.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
