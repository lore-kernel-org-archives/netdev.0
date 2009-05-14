From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: [PATCH 1/2] igb: Implement reading of reg RQDPC
	(Receive Queue	Drop Packet Count)
Date: Thu, 14 May 2009 10:03:08 +0200
Message-ID: <1242288188.18487.127.camel@localhost.localdomain>
References: <1241703346.18487.22.camel@localhost.localdomain>
	<1241703431.18487.25.camel@localhost.localdomain>
	<EA929A9653AAE14F841771FB1DE5A1365F7744D662@rrsmsx501.amr.corp.intel.com>
	<1242035422.18487.78.camel@localhost.localdomain>
	<EA929A9653AAE14F841771FB1DE5A1365F7A1DF466@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365F7A1DF466@rrsmsx501.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 2009-05-13 at 15:07 -0600, Williams, Mitch A wrote:
>  
> >-----Original Message-----
> >From: Jesper Dangaard Brouer [mailto:hawk@comx.dk] 
> >Sent: Monday, May 11, 2009 2:50 AM
> >
> >I have now tested it on a 82575 chip NIC. (I just got my 82575 NIC
> >working again (This 12 port monster from Hotlava Systems, just needed
> >more power on PCIe 100Watt)).
> >
> >I don't see the reason for doing special checks for the 82575. Reading
> >the RQDPC registers on 82575 always returns 0.  I don't see any harm in
> >that!?  (it also returns zero in overload situations)
> >
> >What do you want to redraw your NAK?
> >
> 
> Jesper, I still stand by my NAK.  It's never ever a good idea to read
> non-existent hardware registers.  You don't know what effect those
> reads will have on the hardware.  These addresses may be aliased to other
> registers without being documented.  Hardware designers do this all the
> time to save a few gates in the address decode logic, and these aliases
> may or may not be documented.  If this is the case, reading these
> registers will have unintended consequences.  You might be clearing some
> other statistic, or worse.
> 
> Since we just don't know, it's better to be safe than sorry.  Wrap
> those register reads so they only happen on 82576, and I'll happily
> ack your patch.

Fine, you argumented well for your case.

I'll repost some patches when time permits...

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer


------------------------------------------------------------------------------
The NEW KODAK i700 Series Scanners deliver under ANY circumstances! Your
production scanning environment may not be a perfect world - but thanks to
Kodak, there's a perfect scanner to get the job done! With the NEW KODAK i700
Series Scanner you'll get full speed at 300 dpi even with all image 
processing features enabled. http://p.sf.net/sfu/kodak-com
