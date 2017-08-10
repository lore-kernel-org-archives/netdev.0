From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC net-next] net: Allow name change of IFF_UP interfaces
Date: Thu, 10 Aug 2017 16:10:18 +0200
Message-ID: <20170810141018.GC24790@lunn.ch>
References: <20170809104202.30959-1-vkuznets@redhat.com>
 <CAPA1RqA0q3W-3PsqDpY8_xiBB18SCWTV1gT+BKOTqQfAA5D8Fg@mail.gmail.com>
 <87efskye74.fsf@vitty.brq.redhat.com>
 <20170809161027.GA28694@lunn.ch>
 <871sojyfv0.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ???????????? <hideaki.yoshifuji@miraclelinux.com>,
        network dev <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <871sojyfv0.fsf@vitty.brq.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >> Can you think of any particular real world scenarios which are broken by
> >> the change?
> >
> > How about:
> >
> > man 8 dhclient-script
> >
> > The interface name is passed in $interface to the scripts. Do we get
> > the old name or the new name? I suspect scripts are going to break if
> > they are given the old name, which no longer exists.
> 
> Yes but why would anyone change interface name while dhclient-script is
> running? Things will also go wrong if you try bringing interface down
> during the run or do some other configuration, right?

dhclient already handles the interface going down. sendto/recvfrom
fails and returns an error code. As far as i remember, dhclient then
exits.

> Running multiple configuration tools at the same moment is a bad
> idea, you never know what you're gonna end up with.

It could be argued that configuring an interface vs renaming an
interface are at different levels.

	  Andrew
