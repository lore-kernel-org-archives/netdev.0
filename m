From: "Fischer, Anna" <anna.fischer@hp.com>
Subject: RE: [PATCH][RFC] net/bridge: add basic VEPA support
Date: Tue, 11 Aug 2009 14:30:23 +0000
Message-ID: <0199E0D51A61344794750DC57738F58E6D6AE99C53@GVW1118EXC.americas.hpqcorp.net>
References: <0199E0D51A61344794750DC57738F58E67D2DCECBB@GVW1118EXC.americas.hpqcorp.net>
 <200908081149.27409.arnd@arndb.de>
 <0199E0D51A61344794750DC57738F58E6D6AE99743@GVW1118EXC.americas.hpqcorp.net>
 <200908101707.32751.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: 'Stephen Hemminger' <shemminger@linux-foundation.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"evb@yahoogroups.com" <evb@yahoogroups.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"adobriyan@gmail.com" <adobriyan@gmail.com>,
	"Paul Congdon (UC Davis)" <ptcongdon@ucdavis.edu>,
	Eric Biederman <ebiederm@xmission.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754841AbZHKObN@vger.kernel.org>
In-Reply-To: <200908101707.32751.arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Subject: Re: [PATCH][RFC] net/bridge: add basic VEPA support
> 
> On Monday 10 August 2009, Fischer, Anna wrote:
> > > Subject: Re: [PATCH][RFC] net/bridge: add basic VEPA support
> > >
> > > On Friday 07 August 2009, Paul Congdon (UC Davis) wrote:
> > > > As I understand the macvlan code, it currently doesn't allow two
> VMs
> > > on the
> > > > same machine to communicate with one another.
> > >
> > > There are patches to do that. I think if we add that, there should
> be
> > > a way to choose the behavior between either bridging between the
> > > guests or VEPA.
> >
> > If you implement this direct bridging capability between local VMs
> for
> > macvlan, then would this not break existing applications that
> currently
> > use it? It would be quite a significant change to how macvlan works
> > today. I guess, ideally, you would want to have macvlan work in
> > separate modes, e.g. traditional macvlan, bridging, and VEPA.
> 
> Right, that's what I meant with my sentence above. I'm not sure
> if we need to differentiate traditional macvlan and VEPA though.
> AFAICT, the only difference should be the handling of broadcast
> and multicast frames returning from the hairpin turn. Since this
> does not happen with a traditional macvlan, we can always send them
> to all macvlan ports except the source port.

Yes, if you add a check for the original source port on broadcast/
multicast delivery, then macvlan would be able to function in
basic VEPA mode. 

Maybe it might still be worth preserving the old behaviour, and 
just add an explicit VEPA mode.

 
> > > > I could imagine a hairpin mode on the adjacent bridge making this
> > > > possible, but the macvlan code would need to be updated to filter
> > > > reflected frames so a source did not receive his own packet.
> > >
> > > Right, I missed this point so far. I'll follow up with a patch
> > > to do that.
> >
> > Can you maybe point me to the missing patches for macvlan that you
> > have mentioned in other emails, and the one you mention above?
> > E.g. enabling multicast distribution and allowing local bridging etc.
> > I could not find any of those in the archives. Thanks.
> 
> The patch from Eric Biederman to allow macvlan to bridge between
> its slave ports is at
> 
> http://kerneltrap.org/mailarchive/linux-netdev/2009/3/9/5125774

Looking through the discussions here, it does not seem as if a decision
was made to integrate those patches, because they would make the macvlan
interface behave too much like a bridge. Also, it seems as if there was 
still a problem with doing multicast/broadcast delivery when enabling
local VM-to-VM communication. Is that solved by now?

Thanks,
Anna
