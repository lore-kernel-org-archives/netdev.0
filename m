From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] add stealth mode
Date: Wed, 08 Jul 2015 10:02:01 +0200
Message-ID: <1436342521.2928.4.camel@stressinduktion.org>
References: <CAFnufp059tojfKYBye4eayOCvNNkAE9w_s_6E-PiG-EYp9K0Gg@mail.gmail.com>
	 <21611.1436179798@turing-police.cc.vt.edu>
	 <CAFnufp3xP3xjd8zy0uLKEGgbBAb0motLva=f1EbMJCfcKG=Y-w@mail.gmail.com>
	 <1436256473.3809610.317083993.4E2A41A3@webmail.messagingengine.com>
	 <CAFnufp14J0jmXRy+AgNDyJYSC7OKup-S8ahrrZVFFXF6KDQsRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Matteo Croce <matteo@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFnufp14J0jmXRy+AgNDyJYSC7OKup-S8ahrrZVFFXF6KDQsRg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-07-07 at 17:27 +0200, Matteo Croce wrote:
> 2015-07-07 10:07 GMT+02:00 Hannes Frederic Sowa <
> hannes@stressinduktion.org>:
> > 
> > 
> > On Mon, Jul 6, 2015, at 21:44, Matteo Croce wrote:
> > > 2015-07-06 12:49 GMT+02:00  <Valdis.Kletnieks@vt.edu>:
> > > > On Thu, 02 Jul 2015 10:56:01 +0200, Matteo Croce said:
> > > > > Add option to disable any reply not related to a listening 
> > > > > socket,
> > > > > like RST/ACK for TCP and ICMP Port-Unreachable for UDP.
> > > > > Also disables ICMP replies to echo request and timestamp.
> > > > > The stealth mode can be enabled selectively for a single 
> > > > > interface.
> > > > 
> > > > A few notes.....
> > > > 
> > > > 1) Do you have an actual use case where an iptables '-j DROP' 
> > > > isn't usable?
> > > 
> > > If you mean using a default DROP policy and allowing only the 
> > > traffic
> > > do you want,
> > > then the use case is where the port can change at runtime and you 
> > > may not
> > > want
> > > to update the firewall every time
> > 
> > Can't you use socket match in netfilter to accomplish exactly that?
> 
> You mean the owner --uid match?
> Yes  sort of, but my was a different goal, I want just to disable any
> kind of reply from a specific interface (usually WAN) unless there is
> a listening socket, to mitigate port scanning and flood attacks
> without having a firewall.

I was more thinking about the xt_socket match:

-m socket in the INPUT chain.

> Obviously you can do it with a firewall,
> but why do we have /proc/sys/net/ipv4/icmp_echo_ignore_all when we can
> drop ICMP echoes?

Same arguments apply to that knob, but it is already imported and cannot
be changed anymore. Nowadays we try to avoid adding new sysctls.

Bye,
Hannes
