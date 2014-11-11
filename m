From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net-next 0/3] dev_disable_lro() improvements for stacked
 devices
Date: Tue, 11 Nov 2014 10:05:22 +0100
Message-ID: <20141111090522.GB20586@raspberrypi>
References: <cover.1415692212.git.mkubecek@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jiri Pirko <jiri@resnulli.us>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1415692212.git.mkubecek@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 11, 2014 at 09:21:30AM +0100, Michal Kubecek wrote:
>Large receive offloading is known to cause problems if received packets
>are passed to other host. Therefore the kernel disables it by calling
>dev_disable_lro() whenever a network device is enslaved in a bridge or
>forwarding is enabled for it (or globally). For virtual devices we need
>to disable LRO on the underlying physical device (which is actually
>receiving the packets).
>
>Current dev_disable_lro() code handles this propagation for a vlan
>(including 802.1ad nested vlan), macvlan or a vlan on top of a macvlan.
>This patch adds LRO disabling propagation for
>
>  - macvlan on top of a vlan or any stacked combination of those
>  - bonding
>  - teaming

All of these drivers use the netdev_upper and friends, so why not make it
generic with netdev_for_each_all_lower() in dev_disable_lro()?

>
>In the bonding and teaming case, it is necessary to disable LRO not only
>on slaves when dev_disable_lro() is called but also on any slave (port)
>added later.
>
>Michal Kubecek (3):
>  net: handle more general stacking in dev_disable_lro()
>  team: add helper to check if device is a team master
>  net: propagate LRO disabling to bond and team slaves
>
> drivers/net/bonding/bond_main.c |  3 +++
> drivers/net/team/team.c         |  6 +++++-
> include/linux/netdevice.h       |  7 +++++++
> net/core/dev.c                  | 31 ++++++++++++++++++++++---------
> 4 files changed, 37 insertions(+), 10 deletions(-)
>
>-- 
>1.8.4.5
>
