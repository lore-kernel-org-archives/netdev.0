From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: [PATCH update 2] firewire: net: throttle TX queue before
	running out of tlabels
Date: Sun, 14 Nov 2010 13:52:12 +0200
Message-ID: <1289735532.24539.12.camel@maxim-laptop>
References: <tkrat.036c5d10fb83f85d@s5r6.in-berlin.de>
	<tkrat.39c164e4c52e2fc8@s5r6.in-berlin.de>
	<tkrat.eaac597cf54bb660@s5r6.in-berlin.de>
	<tkrat.83117f4523f0d928@s5r6.in-berlin.de>
	<1289710228.8581.16.camel@maxim-laptop>
	<4CDFAB10.5050800@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4CDFAB10.5050800@s5r6.in-berlin.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sun, 2010-11-14 at 10:25 +0100, Stefan Richter wrote:
> Maxim Levitsky wrote:
> > In fact after lot of testing I see that original patch, 
> > '[PATCH 4/4] firewire: net: throttle TX queue before running out of
> > tlabels' works the best here.
> > With AR fixes, I don't see even a single fwnet_write_complete error on
> > ether side.
> 
> Well, that version missed that the rx path opened up the tx queue again. I.e.
> it did not work as intended.
> 
> > However the 'update 2' (maybe update 1 too, didn't test), lowers
> > desktop->laptop throughput somewhat.
> > (250 vs 227 Mbits/s). I tested this many times.
> > 
> > Actuall raw troughput possible with UDP stream and ether no throttling
> > or higher packets in flight count (I tested 50/30), it 280 Mbits/s.
> 
> Good, I will test deeper queues with a few different controllers here.  As
> long as we keep a margin to 64 so that other traffic besides IPover1394 still
> has a chance to acquire transaction labels, it's OK.
Just tested the 'update 2' with 8-16 margin. Gives me ~250 Mbits/s TCP
easily, and ~280 Mbit/s UDP. Pretty much the maximum its possible to get
out of this hardware.

> 
> > BTW, I still don't understand fully  why my laptop sends only at 180
> > Mbits/s pretty much always regardless of patches or TCP/UDP.
> 
> If it is not CPU bound, then it is because Ricoh did not optimize the AR DMA
> unit as well as Texas Instruments did.
You mean AT, because in the fast case (desktop->laptop), the TI
transmits and Ricoh receives. In slow case Ricoh receives and TI
transmits.
Anyway speeds of new stack beat the old one by significant margin.

Best regards,
	Maxim Levitsky




------------------------------------------------------------------------------
Centralized Desktop Delivery: Dell and VMware Reference Architecture
Simplifying enterprise desktop deployment and management using
Dell EqualLogic storage and VMware View: A highly scalable, end-to-end
client virtualization framework. Read more!
http://p.sf.net/sfu/dell-eql-dev2dev
