From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next v4 4/7] gtp: consolidate gtp socket rx path
Date: Thu, 23 Feb 2017 22:17:35 +0100
Message-ID: <20170223211735.c47ms7yobt2omhgr@nataraja>
References: <20170221101855.23940-1-aschultz@tpip.net>
 <20170221101855.23940-5-aschultz@tpip.net>
 <CALx6S34-H9rzbJjJRGkRqswnOFK7pKg0gMU+JkgK=Nh77dWoiQ@mail.gmail.com>
 <754038178.195270.1487841591136.JavaMail.zimbra@tpip.net>
 <CALx6S34mFZh31Yorq7WMabTO9SPyxOn5=1iSEQV41HguYJ1bDQ@mail.gmail.com>
 <20170223164657.tmj7djdpgcdlm2ri@nataraja>
 <CALx6S36XJfzYS7q2EjgUykAVWb-1aaT4kP2QxYmPdZBSpZaGCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        osmocom-net-gprs <osmocom-net-gprs@lists.osmocom.org>,
        timo lindhorst <timo.lindhorst@travelping.com>,
        Andreas Schultz <aschultz@tpip.net>,
        pablo <pablo@netfilter.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:59825 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751005AbdBXHPH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 02:15:07 -0500
Content-Disposition: inline
In-Reply-To: <CALx6S36XJfzYS7q2EjgUykAVWb-1aaT4kP2QxYmPdZBSpZaGCg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Thu, Feb 23, 2017 at 10:07:03AM -0800, Tom Herbert wrote:
> I'm looking at the GTP encapsulation, it's not particularly complex.
> Is there any real reason why we can't just implement a netdev
> interface with static tunnels and configuration to do performance
> testing and development? For instance, if we want to add GSO/GRO
> support to GTP that's all we really need, the control plane should be
> inconsequential in that case.

As outlined several times in this thread, GTP tunneling is not
symmetric.  The current mainline code can only act as one of the two
roles (GGSN/G-GW), not as the other one.  The rationale is that in 3GPP
networks, that is the only point in the network that takes native IP
data (e.g.from the internet) and puts it into GTP.  At all other places
in the network, you don't have this combination.  By the time the inner
IP data arrives at the mobile phone, it is no longer encapsulated in
GTP, as the lower layers have been adapted one or multiple times to
other protocols by other network elements.

There's a patch that has recently been submitted which adds the
capability for the SGSN/S-GW side of a GTP-U tunnel, but that patch has
so far not been merged (due to concersn about its netlink interface),
and the patch *only* exists for testing, it has no real-world
application in 3GPP networks.

So as of now, it is not possible to run both endpoints of a tunnel in
Linux.

> > For performance testing, you would need a SGSN-side implementation of
> > I'll try to cook up some instructions extending
> > https://osmocom.org/projects/openggsn/wiki/OpenGGSN to cover also
> > sgsnemu for a basic use case of establishing one single tunnel.  That's
> > of course like a manual "HOWTO" and not yet anything that can be tested
> > automatically.
> >
> That would be good. Thanks!

I've spent some hours earlier today on this, I expect the document to be
ready at some point over the weekend.

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
