From: jamal <hadi@cyberus.ca>
Subject: Re: primary and secondary ip addresses
Date: 19 Dec 2004 17:59:28 -0500
Message-ID: <1103497168.1046.218.camel@jzny.localdomain>
References: <200412161153.51251.hasso@estpak.ee>
	 <Pine.LNX.4.61.0412161103320.30452@filer.marasystems.com>
	 <200412161302.42357.hasso@estpak.ee> <41C2F6E5.5010607@cs.columbia.edu>
	 <Pine.LNX.4.61.0412171621200.15793@filer.marasystems.com>
	 <41C30212.6000906@cs.columbia.edu>
	 <20041217112025.27688eb6.davem@davemloft.net>
	 <Pine.LNX.4.61.0412172046320.18698@filer.marasystems.com>
	 <1103487517.1047.181.camel@jzny.localdomain>
	 <20041219214120.GX17302@sunbeam.de.gnumonks.org>
	 <20041219220211.GQ17998@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>,
	Henrik Nordstrom <hno@marasystems.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrea G Forte <andreaf@cs.columbia.edu>, hasso@estpak.ee,
	nhorman@redhat.com, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041219220211.GQ17998@postel.suug.ch>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I had something much simpler in mind.
Basically, promote the next one in line. This would be cleanly backward 
compatible and would be an improvement over whats there (however
medievial it is). Let me see if i can whip something that at least
compiles. Unfortunately i wont have time to chase it to completion of
testing until around xmas when i have time off from work.

cheers,
jamal

On Sun, 2004-12-19 at 17:02, Thomas Graf wrote:
> * Harald Welte <20041219214120.GX17302@sunbeam.de.gnumonks.org> 2004-12-19 22:41
> > On Sun, Dec 19, 2004 at 03:18:37PM -0500, jamal wrote:
> > 
> > > Having said the above, I think it would make sense to have a "promotion"
> > > scheme so that in the case a primary address is deleted, one could
> > > promote the next secondary address in line. But that should be optional.
> > 
> > Oh yes, please.  This would save a lot of headache.  I'm much in favour
> > of such a proposal.
> 
> Agreed, would be nice to have.
> 
> > > Now where is the fireman who wants to do this? I could help cheering
> > > since i know the code.
> > 
> > how would you think it fits best into the current netlink messages?
> 
>  1) IFA_F_PROM_CAND flag and have inet_del_ifa* iterate over its
>     secondary addresses and elect the first with the flag set.
> 
>  2) IFA_PROM_PRIO TLV of type u32 holding a priority where 0 means no
>     candiate. inet_del_ifa* iterates over its secondary addresses and
>     elects the one with the highest prio as new primary address or
>     deletes all addresses if none is found.
> 
> * respectively the equivalent function of the other address families.
> 
> Second variant requires more work but is more flexible so it's
> definitely my favourite. I'm willing to put some effort into this,
> I'm not familiar with all address families though.
> 

