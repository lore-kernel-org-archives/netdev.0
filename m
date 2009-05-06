From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: [PATCH] igb: Record hardware RX overruns in
	net_stats
Date: Wed, 06 May 2009 10:12:42 +0200
Message-ID: <1241597562.5172.25.camel@localhost.localdomain>
References: <1241435206.8115.104.camel@localhost.localdomain>
	<9929d2390905051147y71f34e4bu9f63edc1e5a253a2@mail.gmail.com>
	<20090505.115819.84151021.davem@davemloft.net>
	<Pine.LNX.4.64.0905052249110.1294@ask.diku.dk>
	<273D38FBE7C6FE46A1689FCD014A0B8B49655903@azsmsx505.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>, "Waskiewicz Jr,
	Peter P" <peter.p.waskiewicz.jr@intel.com>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
To: "Ronciak, John" <john.ronciak@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <273D38FBE7C6FE46A1689FCD014A0B8B49655903@azsmsx505.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 2009-05-05 at 15:38 -0700, Ronciak, John wrote:
> >Its really useful for diagnosing problems, and I'm betting 
> >that this is a real-life situation which people is going to experience. We 
> >might as well help our self to more easily identify this issue when people 
> >report drop problems.
>
> The problem is that the RNBC aren't dropped packets as the numbers you
> have show.  

Just to make it clear, I am experiencing dropped packets.  The reason I
positivly know this, is that I'm writing a MPEG2-TS drop detection
netfilter module.  Which were the only reason I discovered the packet
drops and the "hidden" RNBC counter via ethtool.

I have read the datasheeet, and with Jeffrey's detailed explaination, I
do know that this number might be higher than the actually drops I'm
experiencing.


> While we can agree that the MPC are the actual dropped packets and
> could eaily be be used in the fifo overflow count since the packets
> were really dropped.

Well, then I think we should keep MPC as drops, and use the fifo_errors
as an fifo overflow indication containing RNBC count.


> > I think that both MPC and RNBC should be stored in rx_fifo_errors
> > (and of cause still keeping them seperate to ethtool -S).
>
> This would count RNBC packets as packets that the stack did not
> process, which it did.  The MPC packets were not processed by the
> stack and should be counted as dropped.  As you point out, both counts
> are available via ethtool -S.
> 
> >I'll post two patches with these changes tomorrow, for you evaluation.
>
> Thanks, we look forward to see them.

I'll keep it to one patch (with an extra comment reflecting this
disscussion), as you have convinced me that the MPC should stay as
"rx_missed", as this is presented to userspace as a positive drop.


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
