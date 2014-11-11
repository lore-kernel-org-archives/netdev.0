From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net-next 0/3] dev_disable_lro() improvements for stacked
 devices
Date: Tue, 11 Nov 2014 10:34:57 +0100
Message-ID: <20141111093457.GA30178@unicorn.suse.cz>
References: <cover.1415692212.git.mkubecek@suse.cz>
 <20141111090522.GB20586@raspberrypi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jiri Pirko <jiri@resnulli.us>
To: Veaceslav Falico <vfalico@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141111090522.GB20586@raspberrypi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 11, 2014 at 10:05:22AM +0100, Veaceslav Falico wrote:
> On Tue, Nov 11, 2014 at 09:21:30AM +0100, Michal Kubecek wrote:
> >Large receive offloading is known to cause problems if received packets
> >are passed to other host. Therefore the kernel disables it by calling
> >dev_disable_lro() whenever a network device is enslaved in a bridge or
> >forwarding is enabled for it (or globally). For virtual devices we need
> >to disable LRO on the underlying physical device (which is actually
> >receiving the packets).
> >
> >Current dev_disable_lro() code handles this propagation for a vlan
> >(including 802.1ad nested vlan), macvlan or a vlan on top of a macvlan.
> >This patch adds LRO disabling propagation for
> >
> > - macvlan on top of a vlan or any stacked combination of those
> > - bonding
> > - teaming
> 
> All of these drivers use the netdev_upper and friends, so why not make it
> generic with netdev_for_each_all_lower() in dev_disable_lro()?

I wanted to preserve current approach where for vlan and macvlan, LRO is
disabled on the real device instead of the original one (rather than in
addition to it) as LRO is always disabled on them.

Handling all four uniformly would make the code nicer but would bring
unnecessary overhead of traversing the list and dev_disable_lro()
recursion. On the other hand, this operation is not time critical so it
might be acceptable after all.

                                                         Michal Kubecek
