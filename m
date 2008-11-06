From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: IP-less bridge as a martian source
Date: Thu, 6 Nov 2008 13:15:44 +0000
Message-ID: <20081106131544.GB4809@ff.dom.local>
References: <87wsg0wu78.fsf@tac.ki.iif.hu> <48FF614C.7020507@gmail.com> <48FF7AA3.50408@gmail.com> <87y707mjbi.fsf@tac.ki.iif.hu> <20081031084124.GA4364@ff.dom.local> <877i7novar.fsf@szonett.ki.iif.hu> <20081105094303.GA5378@ff.dom.local> <87prla79d6.fsf@tac.ki.iif.hu> <20081106100032.GA4809@ff.dom.local> <873ai5yshm.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ferenc Wagner <wferi@niif.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:57589 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753612AbYKFNPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 08:15:51 -0500
Received: by ug-out-1314.google.com with SMTP id 39so816263ugf.37
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2008 05:15:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <873ai5yshm.fsf@tac.ki.iif.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 06, 2008 at 01:00:05PM +0100, Ferenc Wagner wrote:
> Jarek Poplawski <jarkao2@gmail.com> writes:
...
> > Then I guess we can reconsider this problem like this: since this is a
> > bridge device without any IP address, and "we" expect treating this as
> > IP disabled devices, IMHO it doesn't make much sense to turn rp_filter
> > for such a device; log_martians can report us some other strange
> > address combinations, so it could be useful if there is not too much
> > of this.
> 
> Yes, rp_filter doesn't make any sense on this bridge interface, as
> there should be no traffic to/from the bridging host through this
> bridge.  Still, it shouldn't hurt either, should it?

No, if your regular traffic doesn't need any complex routing.

> 
> >> wferi@xen1:~$ sudo cat /proc/net/vlan/vlan891 
> >> [...]
> >> EGRESSS priority Mappings: 
> >
> > Should be corrected: maybe you will send a patch? (Otherwise let me now.)
> 
> I sent one.  Hope it's OK.

Looks OK to me.

> 
> > Yes, but this 255.255.255.255 address is (or was) special. According
> > to this:
> > http://en.wikipedia.org/wiki/Classful_network
> > and especially this:
> > http://tools.ietf.org/html/draft-wilson-class-e-02
> >
> > it could be changed soon.
> 
> Yes, but I fail to see how this is relevant in either case.  My
> question is: why does the IP-less bridge pick up any packets?
> Does the host-based addressing model require this, if the host has any
> IP address at all (on some other interface)?

Do you mean why it's routed at all? Probably it's something about bridge
configs, like BRIDGE_EBT_BROUTE etc. You could try to analyze net/bridge/
br_input.c/br_handle_frame() for cases when it returns skb (instead of
NULL).

...
> I didn't mean separating the ports of the bridge, but separating the
> host running the bridge from the traffic the bridge forwards.  It
> should be able to forward all the strangest IP or non-IP traffic of
> the world and stay totally unaffected.

Yes, I missed your point. So I think this should be configurable.

> >>> but not all. log_martians should tell you if it's something
> >>> serious. If you have some martians "by design" it's probably
> >>> better to get rid of them before rp_filter
> >> 
> >> By dropping the in the nat table or by ebtables?  Anyway, "martians by
> >> design" does sound particulary sane.
> >
> > I mean e.g. when you really have to treat packets with such unusual
> > addresses as in your pings.
> 
> Yes, I have to.  Some Wake-on-LAN packets also carry 255.255.255.255
> as their destination address.  Just like various Windows/MacOS
> "neighbour discovery" services.

Are you sure they use something else then 0.0.0.0 as a source address
with these 255.255.255.255 packets?

> 
> >>> I agree the syntax of this warning is confusing, but I doubt we
> >>> should change this after so many years - this could break users'
> >>> scripts checking for this.
> >> 
> >> :) It's surprising after having read stable_api_nonsense.txt...
> >
> > Hmm... Could you point me to this most :) point?
> 
> For me, the first paragraph says that the user space interface is the
> syscall interface, and that's the only one you can count on being
> stable; in other cases technical superiority overrides compatibility.
> Not that I feel too strongly in this case.

I think it means things can change if they harm "technical superiority".
The question is if possibly misleading message format can do this too.
I guess the practice is to change such things only if they are
obviously wrong.

Jarek P.
