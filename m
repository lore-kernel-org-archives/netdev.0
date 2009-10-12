From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: Re: [Bug #14252] WARNING: at include/linux/skbuff.h:1382 w/ e1000
Date: Mon, 12 Oct 2009 13:44:21 +0200
Message-ID: <20091012134421.1dcaf78b.skraw@ithnet.com>
References: <56acieJJ2fF.A.nEB.Hzl0KB@chimera>
	<L6tb-VyKHZK.A.9UD.zzl0KB@chimera>
	<20091012.034919.98011643.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rjw@sisk.pl, linux-kernel@vger.kernel.org,
	kernel-testers@vger.kernel.org, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756422AbZJLLpF@vger.kernel.org>
In-Reply-To: <20091012.034919.98011643.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 12 Oct 2009 03:49:19 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: "Rafael J. Wysocki" <rjw@sisk.pl>
> Date: Mon, 12 Oct 2009 01:01:06 +0200 (CEST)
> 
> > This message has been generated automatically as a part of a report
> > of regressions introduced between 2.6.30 and 2.6.31.
> > 
> > The following bug entry is on the current list of known regressions
> > introduced between 2.6.30 and 2.6.31.  Please verify if it still should
> > be listed and let me know (either way).
> > 
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14252
> > Subject		: WARNING: at include/linux/skbuff.h:1382 w/ e1000
> > Submitter	: Stephan von Krawczynski <skraw@ithnet.com>
> > Date		: 2009-09-20 11:26 (22 days old)
> > References	: http://marc.info/?l=linux-kernel&m=125344599006033&w=4
> 
> Hmmm... e1000 calls skb_trim() on both jumbo and non-jumbo ring
> buffers which get recycled.
> 
> At least for the Jumbo case, that's illegal as you cannot call
> skb_trim() on an SKB with paged data.
> 
> But this assertion is triggering for the non-jumbo ring where
> only linear packets should be present as far as I can tell.
> 
> Some Intel folks need to take a look, CC:'d, and people need
> to CC: their networking bug reports to netdev@vger.kernel.org
> so that the proper folks see it.
> 
> Thanks.

Really, this was a lucky catch, because most of the time the box goes dead right away.
Don't interpret "most of the time" as "continously every day". It just happens sometimes. I am not that surprised because it's a box on the "frontline", you can find a lot of trash going on there, like:

Oct 12 12:21:01 box kernel: TCP: Peer 217.231.204.133:61124/80 unexpectedly shrunk window 2348821413:2348838837 (repaired)
Oct 12 12:21:02 box kernel: TCP: Peer 217.231.204.133:61124/80 unexpectedly shrunk window 2348821413:2348838837 (repaired)

-- 
Regards,
Stephan
