From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: [linux-pm] [RFC] Runtime power management on
	ipw2100
Date: Wed, 31 Jan 2007 09:48:58 +0000
Message-ID: <20070131094858.GA23842@srcf.ucam.org>
References: <20070131075249.GA22115@srcf.ucam.org>
	<1170234787.6746.22.camel@amit-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ipw2100-devel@lists.sourceforge.net, linux-pm@lists.osdl.org,
	netdev@vger.kernel.org
To: Amit Kucheria <amit.kucheria@nokia.com>
Return-path: <ipw2100-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <1170234787.6746.22.camel@amit-laptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipw2100-devel>,
	<mailto:ipw2100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ipw2100-devel>
List-Post: <mailto:ipw2100-devel@lists.sourceforge.net>
List-Help: <mailto:ipw2100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipw2100-devel>,
	<mailto:ipw2100-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ipw2100-devel-bounces@lists.sourceforge.net
Errors-To: ipw2100-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Jan 31, 2007 at 11:13:07AM +0200, Amit Kucheria wrote:

> What is the latency in changing between different PCI power states for
> peripherals?

I'm not sure in the general case, but the power-down path for the 
ipw2100 involves a static wait of 100ms in ipw2100_hw_stop_adapter(). 

> Would it be possible e.g. to put the peripheral into a low power state
> after each Tx/Rx (with reasonable hyteresis)?

Most wireless drivers support some degree of power management at this 
scale, but (in ipw2100 at least) it's implemented in the firmware so I 
have absolutely no idea what it's actually doing.

> <snip>
> 
> > The situation is slightly more complicated for wired interfaces. As 
> > previously discussed, we potentially want three interface states (on, 
> > low power, off) with the intermediate one powering down as much of the 
> > hardware as possible while still implementing link detection.
> 
> And this low power state is what the HW should be in all the time,
> except when it has work to do.

PCI seems to require a delay of 10ms when sequencing from D3 to D0, 
which probably isn't acceptable latency for an "up" state. While there's 
definitely a benefit to the sort of PM you're describing (it's a model 
we've already started using on the desktop as far as the CPU goes), I 
think we still want to be able to expose as much power saving as 
possible.

-- 
Matthew Garrett | mjg59@srcf.ucam.org

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
