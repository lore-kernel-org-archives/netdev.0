From: Thorsten Kranzkowski <dl8bcu@dl8bcu.de>
Subject: Re: PROBLEM: Silent data corruption when using sendfile()
Date: Sat, 14 Jul 2012 11:44:31 +0000
Message-ID: <20120714114431.GA1190@ds20.borg.net>
References: <20120713171835.GA26052@vault.local>
 <CAJd=RBAntSubDBbJ292SzeoN4hTwBQ_Q23jt+Y6i-+vfrQ5EHQ@mail.gmail.com>
 <1342254042.3265.9017.camel@edumazet-glaptop>
 <20120714083136.GO16256@1wt.eu>
 <20120714101321.GA26329@vault.local>
 <1342262004.3265.9279.camel@edumazet-glaptop>
Reply-To: dl8bcu@dl8bcu.de
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Truschnigg <johannes@truschnigg.info>,
	Willy Tarreau <w@1wt.eu>, Hillf Danton <dhillf@gmail.com>,
	linux-kernel@vger.kernel.org, Linux-Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.mail.vrmd.de ([81.28.224.28]:53008 "EHLO
	relay2.mail.vrmd.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753125Ab2GNMIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2012 08:08:39 -0400
Content-Disposition: inline
In-Reply-To: <1342262004.3265.9279.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 14, 2012 at 12:33:24PM +0200, Eric Dumazet wrote:
> On Sat, 2012-07-14 at 12:13 +0200, Johannes Truschnigg wrote:
> > On Sat, Jul 14, 2012 at 10:31:36AM +0200, Willy Tarreau wrote:
> > > > Please Johannes could you try latest kernel tree ?
> > > 
> > > It would be useful, especially given the amount of changes you performed
> > > in this area in latest version, it could be very possible that this new
> > > bug got fixed as a side effect !
> > 
> > I upgraded to 3.4.4 (identical config as the 3.4.0 build I've been running)
> > and what can I say - the problem really seems to have disappeared. I performed
> > about 3700 iterations of my previos tests over the night, and the data always
> > turned out to be OK, not a single byte turned out kaput!
> > 
> > I wish I would have tested that earlier, and spared you the noise... well,
> > maybe someone who runs into a similar problem in the future will have this
> > discovery save her/him some time and headaches and make her/him just upgrade
> > kernels :)
> > 
> > Thanks a lot for your polite and quick responses!
> > 
> 
> Nice to hear. Now we should make sure we have all needed fixes for prior
> stable kernels as well !
> 
> Still trying to understand the issue, since I thought I only did
> optimizations, not bug fixes. So maybe real bug is still there but its
> probability of occurrence lowered enough to not hit your workload.
>  
> Hmmm...
> 

Not sure if this is related, but I had a similar data corruption problem:
Reading data from filesystem 'normally' (including through nfs) showed
corruption at random places, mostly 0xff tuning into 0xfe.
Reading with ODIRECT (I used 'dd iflag=direct') was OK.

I found my problem to be fixed by
fffaee365fded09f9ebf2db19066065fa54323c3 (upstrem)
which was backported as
b642cb6a143da812f188307c2661c0357776a9d0 (stable, v3.4.1-66-gb642cb6)


Bye,
Thorsten

-- 
| Thorsten Kranzkowski        Internet: dl8bcu@dl8bcu.de                      |
| Mobile: ++49 170 1876134       Snail: Kiebitzstr. 14, 49324 Melle, Germany  |
| Ampr: dl8bcu@db0lj.#rpl.deu.eu, dl8bcu@marvin.dl8bcu.ampr.org [44.130.8.19] |
