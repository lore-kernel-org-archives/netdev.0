From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: [PATCH] bridge: mask forwarding of IEEE 802 local multicast
 groups
Date: Tue, 13 Sep 2011 15:29:51 -0400
Message-ID: <20110913192951.GA24341@synalogic.ca>
References: <BANLkTi=jnxBu6WzAOTxHD+e_O1qYKE2m=g@mail.gmail.com>
 <CAEJpZP1cr4B9qX6gH9O4iXwWvEdxs2aebL21FnX1BE0dJPHrEw@mail.gmail.com>
 <20110711082755.0b38a15a@nehalam.ftrdhcpuser.net>
 <20110712113643.GC616804@jupiter.n2.diac24.net>
 <CAEJpZP1Da=G3--jThbaj5H4+H+836quXXEfGXtBwdPewr-Pjrg@mail.gmail.com>
 <20110715160357.GC1407585@jupiter.n2.diac24.net>
 <20110715163345.GD1407585@jupiter.n2.diac24.net>
 <20110727111714.GA2027462@jupiter.n2.diac24.net>
 <20110728084106.22166324@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>,
	Nick Carter <ncarter100@gmail.com>, netdev@vger.kernel.org,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	davem@davemloft.net, Ed Swierk <eswierk@bigswitch.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f52.google.com ([209.85.215.52]:38395 "EHLO
	mail-ew0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932079Ab1IMTaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2011 15:30:01 -0400
Received: by ewy28 with SMTP id 28so625726ewy.11
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2011 12:29:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110728084106.22166324@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-07-28 08:41, Stephen Hemminger wrote:
> On Wed, 27 Jul 2011 13:17:15 +0200
> David Lamparter <equinox@diac24.net> wrote:
> 
> > On Fri, Jul 15, 2011 at 06:33:45PM +0200, David Lamparter wrote:
> > > On Fri, Jul 15, 2011 at 06:03:57PM +0200, David Lamparter wrote:
> > > > On Fri, Jul 15, 2011 at 04:44:50PM +0100, Nick Carter wrote:
> > > > > On 12 July 2011 12:36, David Lamparter <equinox@diac24.net> wrote:
> > > > > > On Mon, Jul 11, 2011 at 08:27:55AM -0700, Stephen Hemminger wrote:
> > > > > >> I am still undecided on this. Understand the need, but don't like idea
> > > > > >> of bridge behaving in non-conforming manner. Will see if IEEE 802 committee
> > > > > >> has any input.
> > > > > >
> > > > > > The patch doesn't make the bridge behave nonconformant. The default mask
> > > > > > is 0, which just keeps the old behaviour.
> > > 
> > > P.S.: I'd like to once more stress this. In my opinion the patch should
> > > be merged because it provides desireable functionality at a small cost
> > > (one test, one knob) and __does not change any default behaviour__.
> > 
> > Stephen, anything new on this?
> 
> No.
> Don't like adding yet another hack user visible API which will have
> to be maintained for too long. But on the other hand I don't have
> a better solution at my finger tips. If better idea doesn't come
> along, then we can go with yours.

For virtualization-related problems, how about using macvtap? No need to
change the bridging code.

I had also previously submitted a patch to forward reserved group
addresses through the bridge. This was towards the goal of forwarding
EAPOL frames for virtual machines. I have since come to the realization
that one can use macvtap to achieve that instead. This forgoes the
bridge and offers better performance too.

I have tested macvtap + kvm to authenticate/authorize a virtual machine
connected to a 802.1X enabled switch. I used the instructions here for
macvtap:
http://virt.kernelnewbies.org/MacVTap
and tested with an HP switch and wpa_supplicant on the guest.

-Ben
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
