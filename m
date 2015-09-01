From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH RFC 0/5] net: L2 only interfaces
Date: Tue, 1 Sep 2015 13:07:15 -0400
Message-ID: <20150901170715.GA5919@ketchup.mtl.sfl>
References: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com>
 <20150825232021.GA8482@Alexeis-MacBook-Pro-2.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, andrew@lunn.ch, linux@roeck-us.net,
	jiri@resnulli.us, sfeldma@gmail.com,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-208-88-110-44.savoirfairelinux.net ([208.88.110.44]:42261
	"EHLO mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752290AbbIARHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 13:07:18 -0400
Content-Disposition: inline
In-Reply-To: <20150825232021.GA8482@Alexeis-MacBook-Pro-2.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian, All,

On Aug. Tuesday 25 (35) 04:20 PM, Alexei Starovoitov wrote:
> On Tue, Aug 25, 2015 at 03:50:10PM -0700, Florian Fainelli wrote:
> > Hi all,
> > 
> > This patch series implements a L2 only interface concept which basically denies
> > any kind of IP address configuration on these interfaces, but still allows them
> > to be used as configuration end-points to keep using ethtool and friends.
> > 
> > A cleaner approach might be to finally come up with the concept of net_port
> > which a net_device would be a superset of, but this still raises tons of
> > questions as to whether we should be modifying userland tools to be able to
> > configure/query these interfaces. During all the switch talks/discussions last
> > year, it seemed to me like th L2-only interface is closest we have to a
> > "network port".
> > 
> > Comments, flames, flying tomatoes welcome!
> > 
> > Florian Fainelli (5):
> >   net: add IFF_L2_ONLY flag
> >   net: ipv4: Skip in_dev initialization for IFF_L2_ONLY interfaces
> >   net: ipv6: Skip in6_dev initialization for IFF_L2_ONLY interfaces
> 
> interesting idea! Do you know how kernel/iproute2 will react to lack of in_dev?
> No crashes I'm assuming, but what kind of errors are thrown?
> imo great first step to have lightweight netdevs. +1 for 'net_port' in the future.

Lightening net_device with a new inner net_port structure seems like a
great idea to register and expose L2 only interfaces.

DSA would get benefit from this too, as we could finally expose CPU and
DSA ports. We'll then be able to use standard tools to configure them
(e.g. speed/duplex), and allow fine-grained control of bridging: we may
want to explicitly include or exclude these ports in bridges or VLANs.

Same goes for the support of basic switches (home routers).

A new iproute2 command or additional command line flags can be added
later to explicitly access them from userspace. In the meantime,
ifconfig and such would transparently configure (net_device)->port.

Thanks,
-v
