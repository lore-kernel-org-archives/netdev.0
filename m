From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] dev_disable_lro() improvements for
 stacked devices
Date: Tue, 11 Nov 2014 21:47:52 -0500 (EST)
Message-ID: <20141111.214752.266800170368088905.davem@davemloft.net>
References: <cover.1415692212.git.mkubecek@suse.cz>
	<20141111090522.GB20586@raspberrypi>
	<20141111093457.GA30178@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vfalico@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, j.vosburgh@gmail.com,
	andy@greyhouse.net, jiri@resnulli.us
To: mkubecek@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141111093457.GA30178@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Kubecek <mkubecek@suse.cz>
Date: Tue, 11 Nov 2014 10:34:57 +0100

> On Tue, Nov 11, 2014 at 10:05:22AM +0100, Veaceslav Falico wrote:
>> On Tue, Nov 11, 2014 at 09:21:30AM +0100, Michal Kubecek wrote:
>> >Large receive offloading is known to cause problems if received packets
>> >are passed to other host. Therefore the kernel disables it by calling
>> >dev_disable_lro() whenever a network device is enslaved in a bridge or
>> >forwarding is enabled for it (or globally). For virtual devices we need
>> >to disable LRO on the underlying physical device (which is actually
>> >receiving the packets).
>> >
>> >Current dev_disable_lro() code handles this propagation for a vlan
>> >(including 802.1ad nested vlan), macvlan or a vlan on top of a macvlan.
>> >This patch adds LRO disabling propagation for
>> >
>> > - macvlan on top of a vlan or any stacked combination of those
>> > - bonding
>> > - teaming
>> 
>> All of these drivers use the netdev_upper and friends, so why not make it
>> generic with netdev_for_each_all_lower() in dev_disable_lro()?
> 
> I wanted to preserve current approach where for vlan and macvlan, LRO is
> disabled on the real device instead of the original one (rather than in
> addition to it) as LRO is always disabled on them.
> 
> Handling all four uniformly would make the code nicer but would bring
> unnecessary overhead of traversing the list and dev_disable_lro()
> recursion. On the other hand, this operation is not time critical so it
> might be acceptable after all.

Please do it generically.

Having a special stanza for each layered device type in
dev_disable_lro() is beyond stupid.  Especially when it
can in fact be done cleanly.

THanks.
