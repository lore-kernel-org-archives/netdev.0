From: Peter Kjellstroem <cap@nsc.liu.se>
Subject: Re: e1000>5.2.30 unstable with InterruptThrottleRate=0
Date: Sun, 5 Dec 2004 22:39:42 +0100 (CET)
Message-ID: <Pine.LNX.4.44.0412052230410.13794-100000@papput.nsc.liu.se>
References: <1102278893.3343.116.camel@sfeldma-mobl.dsl-verizon.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Scott Feldman <sfeldma@pobox.com>
In-Reply-To: <1102278893.3343.116.camel@sfeldma-mobl.dsl-verizon.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 5 Dec 2004, Scott Feldman wrote:

> On Sun, 2004-12-05 at 06:04, Peter Kjellstroem wrote:
> >  *
> >  * 5.2.39       3/12/04
> >  * ...
> >  *   o Back out the CSA fix for 82547 as it continues to cause
> >  *     systems lock-ups with production systems.
> 

Yes I found that out and verified it earlier today. The fix in question is 
basically if'ed irq_enable/disable around a small chunk of code like this:

        if(hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2)
                e1000_irq_disable(adapter);

this is the original fix and triggers for both e1000_82547 (your 547EI 
right?) and e1000_82547_rev_2 (my 547GI). If your NIC can't stand the fix 
and mine needs it isn't the obvious solution the following?

        if(hw->mac_type == e1000_82547_rev_2)
                e1000_irq_disable(adapter);

I put this (and corresponding enable chung) in the current e1000 in 2.4.28 
and it works lika a charm (and shouldn't bite your 82547EI).

The rev2 part, 82547GI, pci_id 1075. Is present in a vast number of new 
systems including all (as far as I know) Dell 700, 750, 1750, 1700 and all 
Supermicro p4SC mobos.

Best Regards,
 Peter

> Yes, there was a driver "fix" for this problem that has since been
> pulled out of the production driver because it caused lockups on some
> systems.  I have one of these such systems.  Here's the results on my
> systems with an 82547EI:
> 
> 5.2.22		lockup
> 5.2.30.1	lockup
> 5.2.39		NETDEV reset
> 5.2.52		NETDEV reset
> 5.4.11		NETDEV reset
> 
> For you, with an 82547GI, any driver between 5.2.22 and 5.2.30.1 will
> work because it has the "fix".  See the comment in e1000_intr for these
> drivers.
> 
> So I guess you're not out of luck if you use the 5.2.30 driver.  You
> just can't move forward to a newer driver unless you port the "fix"
> forward.
> 
> -scott
> 
> 
> 

-- 
------------------------------------------------------------
  Peter Kjellstroem              | E-mail: cap@nsc.liu.se
  National Supercomputer Centre  | Office: +46(0)13 281492
  Linkoeping University          | Fax   : +46(0)13 282535
  SE-581 83 Linkoeping           | 
  Sweden                         | http://www.nsc.liu.se
