From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH 8/8] net: Implement socketat.
Date: Thu, 23 Sep 2010 16:54:58 +0200
Message-ID: <20100923145458.GA1160234@jupiter.n2.diac24.net>
References: <m1ocborgq7.fsf@fess.ebiederm.org>
 <m1bp7oq1u8.fsf@fess.ebiederm.org>
 <4C9B162E.7040201@parallels.com>
 <1285240797.5036.5.camel@bigi>
 <4C9B3B06.900@parallels.com>
 <1285242055.5036.9.camel@bigi>
 <4C9B3F9C.8080506@parallels.com>
 <1285243881.5036.22.camel@bigi>
 <4C9B495D.70200@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, "Eric W. Biederman" <ebiederm@xmission.com>,
	linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Ulrich Drepper <drepper@gmail.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Ben Greear <greearb@candelatech.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:45400 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754551Ab0IWO4W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Sep 2010 10:56:22 -0400
Content-Disposition: inline
In-Reply-To: <4C9B495D.70200@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 23, 2010 at 04:34:37PM +0400, Pavel Emelyanov wrote:
> On 09/23/2010 04:11 PM, jamal wrote:
> > On Thu, 2010-09-23 at 15:53 +0400, Pavel Emelyanov wrote:
> > 
> >> Why does it matter? You told, that the usage scenario was to
> >> add routes to container. If I do 2 syscalls instead of 1, is
> >> it THAT worse?
> >>
> > 
> > Anything to do with socket IO that requires namespace awareness
> > applies for usage; it could be tcp/udp/etc socket. If it doesnt
> > make any difference performance wise using one scheme vs other
> > to write/read heavy messages then i dont see an issue and socketat
> > is redundant.
> 
> That's what my point is about - unless we know why would we need it
> we don't need it.
> 
> Eric, please clarify, what is the need in creating a socket in foreign
> net namespace?

Hmm. If you somewhere get the fd to a socket from another namespace, it
definitely does work (I'm currently implementing my "socketat" with fd
passing through AF_UNIX sockets, so i know it works), so the

  setns(other...)
  fd = socket(...)
  setns(orig...)

sequence would certainly work. However, there might be other things
happening inbetween like a signal (imagine AIO particularly). While
signals are user-controllable (and therefore to be managed/excluded by
the user), we need to think if there are other problems with doing this
as sequence?

If there are no other problematic conditions with this, socketat should
probably be moved to a user library.


-David

