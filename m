From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [patch net-next V2] net: introduce ethernet teaming device
Date: Sun, 23 Oct 2011 23:46:32 +0200
Message-ID: <CAJZOPZ+80kZ8-dQLJJ3OYr+fxVw=z=VCQzui2aaif1ga7W-K_g@mail.gmail.com>
References: <1319200747-2508-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com, fubar@us.ibm.com, andy@greyhouse.net,
	tgraf@infradead.org, ebiederm@xmission.com, mirqus@gmail.com,
	kaber@trash.net, greearb@candelatech.com, jesse@nicira.com,
	fbl@redhat.com, benjamin.poirier@gmail.com, jzupka@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:63222 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752196Ab1JWVqh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2011 17:46:37 -0400
Received: by bkbzt19 with SMTP id zt19so7379261bkb.19
        for <netdev@vger.kernel.org>; Sun, 23 Oct 2011 14:46:34 -0700 (PDT)
In-Reply-To: <1319200747-2508-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 21, 2011 at 2:39 PM, Jiri Pirko <jpirko@redhat.com> wrote:
> This patch introduces new network device called team. It supposes to =
be
> very fast, simple, userspace-driven alternative to existing bonding d=
river.

Jiri,

Could you elaborate a little further on the motivation for this
teaming approach/solution vs. the current bonding driver? You say that
it suppose to be very fast, simple  and user space driven, so... do
you find bonding not to be fast enough? or too complex? or the fact
that bonding's driving logic being in the kernel is something you
prefer to see in user-space? anything else?

thanks,

Or.


>
> Userspace library called libteam with couple of demo apps is availabl=
e
> here:
> https://github.com/jpirko/libteam
> Note it's still in its dipers atm.
>
> team<->libteam use generic netlink for communication. That and rtnl
> suppose to be the only way to configure team device, no sysfs etc.
>
> Python binding basis for libteam was recently introduced (some need
> still need to be done on it though). Daemon providing arpmon/miimon
> active-backup functionality will be introduced shortly.
> All what's necessary is already implemented in kernel team driver.
>
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
> v1->v2:
> =A0 =A0 =A0 =A0- modes are made as modules. Makes team more modular a=
nd
> =A0 =A0 =A0 =A0 =A0extendable.
> =A0 =A0 =A0 =A0- several commenters' nitpicks found on v1 were fixed
> =A0 =A0 =A0 =A0- several other bugs were fixed.
> =A0 =A0 =A0 =A0- note I ignored Eric's comment about roundrobin port =
selector
> =A0 =A0 =A0 =A0 =A0as Eric's way may be easily implemented as another=
 mode (mode
> =A0 =A0 =A0 =A0 =A0"random") in future.
> ---
> =A0Documentation/networking/team.txt =A0 =A0 =A0 =A0 | =A0 =A02 +
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A07 +
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =
=A0 =A02 +
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A0 =A01 +
> =A0drivers/net/team/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =
38 +
> =A0drivers/net/team/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
7 +
> =A0drivers/net/team/team.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | 1593=
 +++++++++++++++++++++++++++++
> =A0drivers/net/team/team_mode_activebackup.c | =A0152 +++
> =A0drivers/net/team/team_mode_roundrobin.c =A0 | =A0107 ++
> =A0include/linux/Kbuild =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A0 =A01 +
> =A0include/linux/if.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
| =A0 =A01 +
> =A0include/linux/if_team.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A02=
33 +++++
> =A012 files changed, 2144 insertions(+), 0 deletions(-)
> =A0create mode 100644 Documentation/networking/team.txt
> =A0create mode 100644 drivers/net/team/Kconfig
> =A0create mode 100644 drivers/net/team/Makefile
> =A0create mode 100644 drivers/net/team/team.c
> =A0create mode 100644 drivers/net/team/team_mode_activebackup.c
> =A0create mode 100644 drivers/net/team/team_mode_roundrobin.c
> =A0create mode 100644 include/linux/if_team.h
>
> diff --git a/Documentation/networking/team.txt b/Documentation/networ=
king/team.txt
> new file mode 100644
> index 0000000..5a01368
> --- /dev/null
> +++ b/Documentation/networking/team.txt
> @@ -0,0 +1,2 @@
> +Team devices are driven from userspace via libteam library which is =
here:
> + =A0 =A0 =A0 https://github.com/jpirko/libteam
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 5008b08..c33400d 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -6372,6 +6372,13 @@ W: =A0 =A0 =A0 http://tcp-lp-mod.sourceforge.n=
et/
> =A0S: =A0 =A0 Maintained
> =A0F: =A0 =A0 net/ipv4/tcp_lp.c
>
> +TEAM DRIVER
> +M: =A0 =A0 Jiri Pirko <jpirko@redhat.com>
> +L: =A0 =A0 netdev@vger.kernel.org
> +S: =A0 =A0 Supported
> +F: =A0 =A0 drivers/net/team/
> +F: =A0 =A0 include/linux/if_team.h
> +
> =A0TEGRA SUPPORT
> =A0M: =A0 =A0 Colin Cross <ccross@android.com>
> =A0M: =A0 =A0 Erik Gilling <konkers@android.com>
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 583f66c..b3020be 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -125,6 +125,8 @@ config IFB
> =A0 =A0 =A0 =A0 =A0'ifb1' etc.
> =A0 =A0 =A0 =A0 =A0Look at the iproute2 documentation directory for u=
sage etc
>
> +source "drivers/net/team/Kconfig"
> +
> =A0config MACVLAN
> =A0 =A0 =A0 =A0tristate "MAC-VLAN support (EXPERIMENTAL)"
> =A0 =A0 =A0 =A0depends on EXPERIMENTAL
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index fa877cd..4e4ebfe 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -17,6 +17,7 @@ obj-$(CONFIG_NET) +=3D Space.o loopback.o
> =A0obj-$(CONFIG_NETCONSOLE) +=3D netconsole.o
> =A0obj-$(CONFIG_PHYLIB) +=3D phy/
> =A0obj-$(CONFIG_RIONET) +=3D rionet.o
> +obj-$(CONFIG_NET_TEAM) +=3D team/
> =A0obj-$(CONFIG_TUN) +=3D tun.o
> =A0obj-$(CONFIG_VETH) +=3D veth.o
> =A0obj-$(CONFIG_VIRTIO_NET) +=3D virtio_net.o
> diff --git a/drivers/net/team/Kconfig b/drivers/net/team/Kconfig
> new file mode 100644
> index 0000000..70a43a6
> --- /dev/null
> +++ b/drivers/net/team/Kconfig
> @@ -0,0 +1,38 @@
> +menuconfig NET_TEAM
> + =A0 =A0 =A0 tristate "Ethernet team driver support (EXPERIMENTAL)"
> + =A0 =A0 =A0 depends on EXPERIMENTAL
> + =A0 =A0 =A0 ---help---
> + =A0 =A0 =A0 =A0 This allows one to create virtual interfaces that t=
eams together
> + =A0 =A0 =A0 =A0 multiple ethernet devices.
> +
> + =A0 =A0 =A0 =A0 Team devices can be added using the "ip" command fr=
om the
> + =A0 =A0 =A0 =A0 iproute2 package:
> +
> + =A0 =A0 =A0 =A0 "ip link add link [ address MAC ] [ NAME ] type tea=
m"
> +
> + =A0 =A0 =A0 =A0 To compile this driver as a module, choose M here: =
the module
> + =A0 =A0 =A0 =A0 will be called team.
> +
> +if NET_TEAM
> +
> +config NET_TEAM_MODE_ROUNDROBIN
> + =A0 =A0 =A0 tristate "Round-robin mode support"
> + =A0 =A0 =A0 depends on NET_TEAM
> + =A0 =A0 =A0 ---help---
> + =A0 =A0 =A0 =A0 Basic mode where port used for transmitting packets=
 is selected in
> + =A0 =A0 =A0 =A0 round-robin fashion using packet counter.
> +
> + =A0 =A0 =A0 =A0 To compile this team mode as a module, choose M her=
e: the module
> + =A0 =A0 =A0 =A0 will be called team_mode_roundrobin.
> +
> +config NET_TEAM_MODE_ACTIVEBACKUP
> + =A0 =A0 =A0 tristate "Active-backup mode support"
> + =A0 =A0 =A0 depends on NET_TEAM
> + =A0 =A0 =A0 ---help---
> + =A0 =A0 =A0 =A0 Only one port is active at a time and the rest of p=
orts are used
> + =A0 =A0 =A0 =A0 for backup.
> +
> + =A0 =A0 =A0 =A0 To compile this team mode as a module, choose M her=
e: the module
> + =A0 =A0 =A0 =A0 will be called team_mode_activebackup.
> +
> +endif # NET_TEAM
> diff --git a/drivers/net/team/Makefile b/drivers/net/team/Makefile
> new file mode 100644
> index 0000000..85f2028
> --- /dev/null
> +++ b/drivers/net/team/Makefile
> @@ -0,0 +1,7 @@
> +#
> +# Makefile for the network team driver
> +#
> +
> +obj-$(CONFIG_NET_TEAM) +=3D team.o
> +obj-$(CONFIG_NET_TEAM_MODE_ROUNDROBIN) +=3D team_mode_roundrobin.o
> +obj-$(CONFIG_NET_TEAM_MODE_ACTIVEBACKUP) +=3D team_mode_activebackup=
=2Eo
> diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
> new file mode 100644
> index 0000000..398be58
> --- /dev/null
> +++ b/drivers/net/team/team.c
> @@ -0,0 +1,1593 @@
> +/*
> + * net/drivers/team/team.c - Network team device driver
> + * Copyright (c) 2011 Jiri Pirko <jpirko@redhat.com>
> + *
> + * This program is free software; you can redistribute it and/or mod=
ify
> + * it under the terms of the GNU General Public License as published=
 by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/slab.h>
> +#include <linux/rcupdate.h>
> +#include <linux/errno.h>
> +#include <linux/ctype.h>
> +#include <linux/notifier.h>
> +#include <linux/netdevice.h>
> +#include <linux/if_arp.h>
> +#include <linux/socket.h>
> +#include <linux/etherdevice.h>
> +#include <linux/rtnetlink.h>
> +#include <net/rtnetlink.h>
> +#include <net/genetlink.h>
> +#include <net/netlink.h>
> +#include <linux/if_team.h>
> +
> +#define DRV_NAME "team"
> +
> +
> +/**********
> + * Helpers
> + **********/
> +
> +#define team_port_exists(dev) (dev->priv_flags & IFF_TEAM_PORT)
> +
> +static struct team_port *team_port_get_rcu(const struct net_device *=
dev)
> +{
> + =A0 =A0 =A0 struct team_port *port =3D rcu_dereference(dev->rx_hand=
ler_data);
> +
> + =A0 =A0 =A0 return team_port_exists(dev) ? port : NULL;
> +}
> +
> +static struct team_port *team_port_get_rtnl(const struct net_device =
*dev)
> +{
> + =A0 =A0 =A0 struct team_port *port =3D rtnl_dereference(dev->rx_han=
dler_data);
> +
> + =A0 =A0 =A0 return team_port_exists(dev) ? port : NULL;
> +}
> +
> +/*
> + * Since the ability to change mac address for open port device is t=
ested in
> + * team_port_add, this function can be called without control of ret=
urn value
> + */
> +static int __set_port_mac(struct net_device *port_dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const unsigned char=
 *dev_addr)
> +{
> + =A0 =A0 =A0 struct sockaddr addr;
> +
> + =A0 =A0 =A0 memcpy(addr.sa_data, dev_addr, ETH_ALEN);
> + =A0 =A0 =A0 addr.sa_family =3D ARPHRD_ETHER;
> + =A0 =A0 =A0 return dev_set_mac_address(port_dev, &addr);
> +}
> +
> +int team_port_set_orig_mac(struct team_port *port)
> +{
> + =A0 =A0 =A0 return __set_port_mac(port->dev, port->orig.dev_addr);
> +}
> +EXPORT_SYMBOL(team_port_set_orig_mac);
> +
> +int team_port_set_team_mac(struct team_port *port)
> +{
> + =A0 =A0 =A0 return __set_port_mac(port->dev, port->team->dev->dev_a=
ddr);
> +}
> +EXPORT_SYMBOL(team_port_set_team_mac);
> +
> +
> +/*******************
> + * Options handling
> + *******************/
> +
> +void team_options_register(struct team *team, struct team_option *op=
tion,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0size_t option_co=
unt)
> +{
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < option_count; i++, option++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_add_tail(&option->list, &team->opt=
ion_list);
> +}
> +EXPORT_SYMBOL(team_options_register);
> +
> +static void __team_options_change_check(struct team *team,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 struct team_option *changed_option);
> +
> +static void __team_options_unregister(struct team *team,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct team_option *option,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 size_t option_count)
> +{
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < option_count; i++, option++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&option->list);
> +}
> +
> +void team_options_unregister(struct team *team, struct team_option *=
option,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0size_t optio=
n_count)
> +{
> + =A0 =A0 =A0 __team_options_unregister(team, option, option_count);
> + =A0 =A0 =A0 __team_options_change_check(team, NULL);
> +}
> +EXPORT_SYMBOL(team_options_unregister);
> +
> +static int team_option_get(struct team *team, struct team_option *op=
tion,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void *arg)
> +{
> + =A0 =A0 =A0 return option->getter(team, arg);
> +}
> +
> +static int team_option_set(struct team *team, struct team_option *op=
tion,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void *arg)
> +{
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 err =3D option->setter(team, arg);
> + =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> +
> + =A0 =A0 =A0 __team_options_change_check(team, option);
> + =A0 =A0 =A0 return err;
> +}
> +
> +/****************
> + * Mode handling
> + ****************/
> +
> +static LIST_HEAD(mode_list);
> +static DEFINE_SPINLOCK(mode_list_lock);
> +
> +static struct team_mode *__find_mode(const char *kind)
> +{
> + =A0 =A0 =A0 struct team_mode *mode;
> +
> + =A0 =A0 =A0 list_for_each_entry(mode, &mode_list, list) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (strcmp(mode->kind, kind) =3D=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return mode;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return NULL;
> +}
> +
> +static bool is_good_mode_name(const char *name)
> +{
> + =A0 =A0 =A0 while (*name !=3D '\0') {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!isalpha(*name) && !isdigit(*name) =
&& *name !=3D '_')
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 name++;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return true;
> +}
> +
> +int team_mode_register(struct team_mode *mode)
> +{
> + =A0 =A0 =A0 int err =3D 0;
> +
> + =A0 =A0 =A0 if (!is_good_mode_name(mode->kind) ||
> + =A0 =A0 =A0 =A0 =A0 mode->priv_size > TEAM_MODE_PRIV_SIZE)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 spin_lock(&mode_list_lock);
> + =A0 =A0 =A0 if (__find_mode(mode->kind)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EEXIST;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto unlock;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 list_add_tail(&mode->list, &mode_list);
> +unlock:
> + =A0 =A0 =A0 spin_unlock(&mode_list_lock);
> + =A0 =A0 =A0 return err;
> +}
> +EXPORT_SYMBOL(team_mode_register);
> +
> +int team_mode_unregister(struct team_mode *mode)
> +{
> + =A0 =A0 =A0 spin_lock(&mode_list_lock);
> + =A0 =A0 =A0 list_del_init(&mode->list);
> + =A0 =A0 =A0 spin_unlock(&mode_list_lock);
> + =A0 =A0 =A0 return 0;
> +}
> +EXPORT_SYMBOL(team_mode_unregister);
> +
> +static struct team_mode *team_mode_get(const char *kind)
> +{
> + =A0 =A0 =A0 struct team_mode *mode;
> +
> + =A0 =A0 =A0 spin_lock(&mode_list_lock);
> + =A0 =A0 =A0 mode =3D __find_mode(kind);
> + =A0 =A0 =A0 if (!mode) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&mode_list_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 request_module("team-mode-%s", kind);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&mode_list_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mode =3D __find_mode(kind);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (mode)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!try_module_get(mode->owner))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mode =3D NULL;
> +
> + =A0 =A0 =A0 spin_unlock(&mode_list_lock);
> + =A0 =A0 =A0 return mode;
> +}
> +
> +static void team_mode_put(const char *kind)
> +{
> + =A0 =A0 =A0 struct team_mode *mode;
> +
> + =A0 =A0 =A0 spin_lock(&mode_list_lock);
> + =A0 =A0 =A0 mode =3D __find_mode(kind);
> + =A0 =A0 =A0 BUG_ON(!mode);
> + =A0 =A0 =A0 module_put(mode->owner);
> + =A0 =A0 =A0 spin_unlock(&mode_list_lock);
> +}
> +
> +/*
> + * We can benefit from the fact that it's ensured no port is present
> + * at the time of mode change.
> + */
> +static int __team_change_mode(struct team *team,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struc=
t team_mode *new_mode)
> +{
> + =A0 =A0 =A0 /* Check if mode was previously set and do cleanup if s=
o */
> + =A0 =A0 =A0 if (team->mode_kind) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 void (*exit_op)(struct team *team) =3D =
team->mode_ops.exit;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Clear ops area so no callback is cal=
led any longer */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(&team->mode_ops, 0, sizeof(struc=
t team_mode_ops));
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 synchronize_rcu();
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (exit_op)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 exit_op(team);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 team_mode_put(team->mode_kind);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 team->mode_kind =3D NULL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* zero private data area */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(&team->mode_priv, 0,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sizeof(struct team) - of=
fsetof(struct team, mode_priv));
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (!new_mode)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> +
> + =A0 =A0 =A0 if (new_mode->ops->init) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D new_mode->ops->init(team);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 team->mode_kind =3D new_mode->kind;
> + =A0 =A0 =A0 memcpy(&team->mode_ops, new_mode->ops, sizeof(struct te=
am_mode_ops));
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int team_change_mode(struct team *team, const char *kind)
> +{
> + =A0 =A0 =A0 struct team_mode *new_mode;
> + =A0 =A0 =A0 struct net_device *dev =3D team->dev;
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 if (!list_empty(&team->port_list)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_err(dev, "No ports can be presen=
t during mode change\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBUSY;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (team->mode_kind && strcmp(team->mode_kind, kind) =3D=
=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_err(dev, "Unable to change to th=
e same mode the team is in\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 new_mode =3D team_mode_get(kind);
> + =A0 =A0 =A0 if (!new_mode) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_err(dev, "Mode \"%s\" not found\=
n", kind);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 err =3D __team_change_mode(team, new_mode);
> + =A0 =A0 =A0 if (err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_err(dev, "Failed to change to mo=
de \"%s\"\n", kind);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 team_mode_put(kind);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 netdev_info(dev, "Mode changed to \"%s\"\n", kind);
> + =A0 =A0 =A0 return 0;
> +}
> +
> +
> +/************************
> + * Rx path frame handler
> + ************************/
> +
> +/* note: already called with rcu_read_lock */
> +static rx_handler_result_t team_handle_frame(struct sk_buff **pskb)
> +{
> + =A0 =A0 =A0 struct sk_buff *skb =3D *pskb;
> + =A0 =A0 =A0 struct team_port *port;
> + =A0 =A0 =A0 struct team *team;
> + =A0 =A0 =A0 rx_handler_result_t res =3D RX_HANDLER_ANOTHER;
> +
> + =A0 =A0 =A0 skb =3D skb_share_check(skb, GFP_ATOMIC);
> + =A0 =A0 =A0 if (!skb)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return RX_HANDLER_CONSUMED;
> +
> + =A0 =A0 =A0 *pskb =3D skb;
> +
> + =A0 =A0 =A0 port =3D team_port_get_rcu(skb->dev);
> + =A0 =A0 =A0 team =3D port->team;
> +
> + =A0 =A0 =A0 if (team->mode_ops.receive)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 res =3D team->mode_ops.receive(team, po=
rt, skb);
> +
> + =A0 =A0 =A0 if (res =3D=3D RX_HANDLER_ANOTHER) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct team_pcpu_stats *pcpu_stats;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pcpu_stats =3D this_cpu_ptr(team->pcpu_=
stats);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64_stats_update_begin(&pcpu_stats->syn=
cp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pcpu_stats->rx_packets++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pcpu_stats->rx_bytes +=3D skb->len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb->pkt_type =3D=3D PACKET_MULTICA=
ST)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pcpu_stats->rx_multicas=
t++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64_stats_update_end(&pcpu_stats->syncp=
);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->dev =3D team->dev;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 this_cpu_inc(team->pcpu_stats->rx_dropp=
ed);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return res;
> +}
> +
> +
> +/****************
> + * Port handling
> + ****************/
> +
> +static bool team_port_find(const struct team *team,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const struct tea=
m_port *port)
> +{
> + =A0 =A0 =A0 struct team_port *cur;
> +
> + =A0 =A0 =A0 list_for_each_entry(cur, &team->port_list, list)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cur =3D=3D port)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> + =A0 =A0 =A0 return false;
> +}
> +
> +static int team_port_list_init(struct team *team)
> +{
> + =A0 =A0 =A0 int i;
> + =A0 =A0 =A0 struct hlist_head *hash;
> +
> + =A0 =A0 =A0 hash =3D kmalloc(sizeof(*hash) * TEAM_PORT_HASHENTRIES,=
 GFP_KERNEL);
> + =A0 =A0 =A0 if (!hash)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < TEAM_PORT_HASHENTRIES; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_HLIST_HEAD(&hash[i]);
> + =A0 =A0 =A0 team->port_hlist =3D hash;
> + =A0 =A0 =A0 INIT_LIST_HEAD(&team->port_list);
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static void team_port_list_fini(struct team *team)
> +{
> + =A0 =A0 =A0 kfree(team->port_hlist);
> +}
> +
> +/*
> + * Add/delete port to the team port list. Write guarded by rtnl_lock=
=2E
> + * Takes care of correct port->index setup (might be racy).
> + */
> +static void team_port_list_add_port(struct team *team,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 struct team_port *port)
> +{
> + =A0 =A0 =A0 port->index =3D team->port_count++;
> + =A0 =A0 =A0 hlist_add_head_rcu(&port->hlist,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0team_port_index_=
hash(team, port->index));
> + =A0 =A0 =A0 list_add_tail_rcu(&port->list, &team->port_list);
> +}
> +
> +static void __reconstruct_port_hlist(struct team *team, int rm_index=
)
> +{
> + =A0 =A0 =A0 int i;
> + =A0 =A0 =A0 struct team_port *port;
> +
> + =A0 =A0 =A0 for (i =3D rm_index + 1; i < team->port_count; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 port =3D team_get_port_by_index_rcu(tea=
m, i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hlist_del_rcu(&port->hlist);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 port->index--;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hlist_add_head_rcu(&port->hlist,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
team_port_index_hash(team, port->index));
> + =A0 =A0 =A0 }
> +}
> +
> +static void team_port_list_del_port(struct team *team,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
struct team_port *port)
> +{
> + =A0 =A0 =A0 int rm_index =3D port->index;
> +
> + =A0 =A0 =A0 hlist_del_rcu(&port->hlist);
> + =A0 =A0 =A0 list_del_rcu(&port->list);
> + =A0 =A0 =A0 __reconstruct_port_hlist(team, rm_index);
> + =A0 =A0 =A0 team->port_count--;
> +}
> +
> +#define TEAM_VLAN_FEATURES (NETIF_F_ALL_CSUM | NETIF_F_SG | \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NETIF_F_FRAGLIS=
T | NETIF_F_ALL_TSO | \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NETIF_F_HIGHDMA=
 | NETIF_F_LRO)
> +
> +static void __team_compute_features(struct team *team)
> +{
> + =A0 =A0 =A0 struct team_port *port;
> + =A0 =A0 =A0 u32 vlan_features =3D TEAM_VLAN_FEATURES;
> + =A0 =A0 =A0 unsigned short max_hard_header_len =3D ETH_HLEN;
> +
> + =A0 =A0 =A0 list_for_each_entry(port, &team->port_list, list) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlan_features =3D netdev_increment_feat=
ures(vlan_features,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 port->dev->vlan_features,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 TEAM_VLAN_FEATURES);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (port->dev->hard_header_len > max_ha=
rd_header_len)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 max_hard_header_len =3D=
 port->dev->hard_header_len;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 team->dev->vlan_features =3D vlan_features;
> + =A0 =A0 =A0 team->dev->hard_header_len =3D max_hard_header_len;
> +
> + =A0 =A0 =A0 netdev_change_features(team->dev);
> +}
> +
> +static void team_compute_features(struct team *team)
> +{
> + =A0 =A0 =A0 spin_lock(&team->lock);
> + =A0 =A0 =A0 __team_compute_features(team);
> + =A0 =A0 =A0 spin_unlock(&team->lock);
> +}
> +
> +static int team_port_enter(struct team *team, struct team_port *port=
)
> +{
> + =A0 =A0 =A0 int err =3D 0;
> +
> + =A0 =A0 =A0 dev_hold(team->dev);
> + =A0 =A0 =A0 port->dev->priv_flags |=3D IFF_TEAM_PORT;
> + =A0 =A0 =A0 if (team->mode_ops.port_enter) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D team->mode_ops.port_enter(team,=
 port);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_err(team->dev, "=
Device %s failed to enter team mode\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
port->dev->name);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return err;
> +}
> +
> +static void team_port_leave(struct team *team, struct team_port *por=
t)
> +{
> + =A0 =A0 =A0 if (team->mode_ops.port_leave)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 team->mode_ops.port_leave(team, port);
> + =A0 =A0 =A0 port->dev->priv_flags &=3D ~IFF_TEAM_PORT;
> + =A0 =A0 =A0 dev_put(team->dev);
> +}
> +
> +static void __team_port_change_check(struct team_port *port, bool li=
nkup);
> +
> +static int team_port_add(struct team *team, struct net_device *port_=
dev)
> +{
> + =A0 =A0 =A0 struct net_device *dev =3D team->dev;
> + =A0 =A0 =A0 struct team_port *port;
> + =A0 =A0 =A0 char *portname =3D port_dev->name;
> + =A0 =A0 =A0 char tmp_addr[ETH_ALEN];
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 if (port_dev->flags & IFF_LOOPBACK ||
> + =A0 =A0 =A0 =A0 =A0 port_dev->type !=3D ARPHRD_ETHER) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_err(dev, "Device %s is of an uns=
upported type\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0portname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (team_port_exists(port_dev)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_err(dev, "Device %s is already a=
 port "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "of a t=
eam device\n", portname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBUSY;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (port_dev->flags & IFF_UP) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_err(dev, "Device %s is up. Set i=
t down before adding it as a team port\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0portname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBUSY;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 port =3D kzalloc(sizeof(struct team_port), GFP_KERNEL);
> + =A0 =A0 =A0 if (!port)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 port->dev =3D port_dev;
> + =A0 =A0 =A0 port->team =3D team;
> +
> + =A0 =A0 =A0 port->orig.mtu =3D port_dev->mtu;
> + =A0 =A0 =A0 err =3D dev_set_mtu(port_dev, dev->mtu);
> + =A0 =A0 =A0 if (err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_dbg(dev, "Error %d calling dev_s=
et_mtu\n", err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_set_mtu;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 memcpy(port->orig.dev_addr, port_dev->dev_addr, ETH_ALE=
N);
> + =A0 =A0 =A0 random_ether_addr(tmp_addr);
> + =A0 =A0 =A0 err =3D __set_port_mac(port_dev, tmp_addr);
> + =A0 =A0 =A0 if (err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_dbg(dev, "Device %s mac addr set=
 failed\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0portname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_set_mac_rand;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 err =3D dev_open(port_dev);
> + =A0 =A0 =A0 if (err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_dbg(dev, "Device %s opening fail=
ed\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0portname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_dev_open;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 err =3D team_port_set_orig_mac(port);
> + =A0 =A0 =A0 if (err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_dbg(dev, "Device %s mac addr set=
 failed - Device does not support addr change when it's opened\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0portname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_set_mac_opened;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 err =3D team_port_enter(team, port);
> + =A0 =A0 =A0 if (err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_err(dev, "Device %s failed to en=
ter team mode\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0portname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_port_enter;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 err =3D netdev_set_master(port_dev, dev);
> + =A0 =A0 =A0 if (err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_err(dev, "Device %s failed to se=
t master\n", portname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_set_master;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 err =3D netdev_rx_handler_register(port_dev, team_handl=
e_frame,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0port);
> + =A0 =A0 =A0 if (err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_err(dev, "Device %s failed to re=
gister rx_handler\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0portname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_handler_register;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 team_port_list_add_port(team, port);
> + =A0 =A0 =A0 __team_compute_features(team);
> + =A0 =A0 =A0 __team_port_change_check(port, !!netif_carrier_ok(port_=
dev));
> +
> + =A0 =A0 =A0 netdev_info(dev, "Port device %s added\n", portname);
> +
> + =A0 =A0 =A0 return 0;
> +
> +err_handler_register:
> + =A0 =A0 =A0 netdev_set_master(port_dev, NULL);
> +
> +err_set_master:
> + =A0 =A0 =A0 team_port_leave(team, port);
> +
> +err_port_enter:
> +err_set_mac_opened:
> + =A0 =A0 =A0 dev_close(port_dev);
> +
> +err_dev_open:
> + =A0 =A0 =A0 team_port_set_orig_mac(port);
> +
> +err_set_mac_rand:
> + =A0 =A0 =A0 dev_set_mtu(port_dev, port->orig.mtu);
> +
> +err_set_mtu:
> + =A0 =A0 =A0 kfree(port);
> +
> + =A0 =A0 =A0 return err;
> +}
> +
> +static int team_port_del(struct team *team, struct net_device *port_=
dev)
> +{
> + =A0 =A0 =A0 struct net_device *dev =3D team->dev;
> + =A0 =A0 =A0 struct team_port *port;
> + =A0 =A0 =A0 char *portname =3D port_dev->name;
> +
> + =A0 =A0 =A0 port =3D team_port_get_rtnl(port_dev);
> + =A0 =A0 =A0 if (!port || !team_port_find(team, port)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_err(dev, "Device %s does not act=
 as a port of this team\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0portname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOENT;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 __team_port_change_check(port, false);
> + =A0 =A0 =A0 team_port_list_del_port(team, port);
> + =A0 =A0 =A0 netdev_rx_handler_unregister(port_dev);
> + =A0 =A0 =A0 netdev_set_master(port_dev, NULL);
> + =A0 =A0 =A0 team_port_leave(team, port);
> + =A0 =A0 =A0 dev_close(port_dev);
> + =A0 =A0 =A0 team_port_set_orig_mac(port);
> + =A0 =A0 =A0 dev_set_mtu(port_dev, port->orig.mtu);
> + =A0 =A0 =A0 synchronize_rcu();
> + =A0 =A0 =A0 kfree(port);
> + =A0 =A0 =A0 netdev_info(dev, "Port device %s removed\n", portname);
> + =A0 =A0 =A0 __team_compute_features(team);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +
> +/*****************
> + * Net device ops
> + *****************/
> +
> +static const char team_no_mode_kind[] =3D "*NOMODE*";
> +
> +static int team_mode_option_get(struct team *team, void *arg)
> +{
> + =A0 =A0 =A0 const char **str =3D arg;
> +
> + =A0 =A0 =A0 *str =3D team->mode_kind ? team->mode_kind : team_no_mo=
de_kind;
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int team_mode_option_set(struct team *team, void *arg)
> +{
> + =A0 =A0 =A0 const char **str =3D arg;
> +
> + =A0 =A0 =A0 return team_change_mode(team, *str);
> +}
> +
> +static struct team_option team_options[] =3D {
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "mode",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .type =3D TEAM_OPTION_TYPE_STRING,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .getter =3D team_mode_option_get,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .setter =3D team_mode_option_set,
> + =A0 =A0 =A0 },
> +};
> +
> +static int team_init(struct net_device *dev)
> +{
> + =A0 =A0 =A0 struct team *team =3D netdev_priv(dev);
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 team->dev =3D dev;
> + =A0 =A0 =A0 spin_lock_init(&team->lock);
> +
> + =A0 =A0 =A0 team->pcpu_stats =3D alloc_percpu(struct team_pcpu_stat=
s);
> + =A0 =A0 =A0 if (!team->pcpu_stats)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 err =3D team_port_list_init(team);
> + =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_port_list_init;
> +
> + =A0 =A0 =A0 INIT_LIST_HEAD(&team->option_list);
> + =A0 =A0 =A0 team_options_register(team, team_options, ARRAY_SIZE(te=
am_options));
> + =A0 =A0 =A0 netif_carrier_off(dev);
> +
> + =A0 =A0 =A0 return 0;
> +
> +err_port_list_init:
> +
> + =A0 =A0 =A0 free_percpu(team->pcpu_stats);
> +
> + =A0 =A0 =A0 return err;
> +}
> +
> +static void team_uninit(struct net_device *dev)
> +{
> + =A0 =A0 =A0 struct team *team =3D netdev_priv(dev);
> + =A0 =A0 =A0 struct team_port *port;
> + =A0 =A0 =A0 struct team_port *tmp;
> +
> + =A0 =A0 =A0 spin_lock(&team->lock);
> + =A0 =A0 =A0 list_for_each_entry_safe(port, tmp, &team->port_list, l=
ist)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 team_port_del(team, port->dev);
> +
> + =A0 =A0 =A0 __team_change_mode(team, NULL); /* cleanup */
> + =A0 =A0 =A0 __team_options_unregister(team, team_options, ARRAY_SIZ=
E(team_options));
> + =A0 =A0 =A0 spin_unlock(&team->lock);
> +}
> +
> +static void team_destructor(struct net_device *dev)
> +{
> + =A0 =A0 =A0 struct team *team =3D netdev_priv(dev);
> +
> + =A0 =A0 =A0 team_port_list_fini(team);
> + =A0 =A0 =A0 free_percpu(team->pcpu_stats);
> + =A0 =A0 =A0 free_netdev(dev);
> +}
> +
> +static int team_open(struct net_device *dev)
> +{
> + =A0 =A0 =A0 netif_carrier_on(dev);
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int team_close(struct net_device *dev)
> +{
> + =A0 =A0 =A0 netif_carrier_off(dev);
> + =A0 =A0 =A0 return 0;
> +}
> +
> +/*
> + * note: already called with rcu_read_lock
> + */
> +static netdev_tx_t team_xmit(struct sk_buff *skb, struct net_device =
*dev)
> +{
> + =A0 =A0 =A0 struct team *team =3D netdev_priv(dev);
> + =A0 =A0 =A0 bool tx_success =3D false;
> + =A0 =A0 =A0 unsigned int len =3D skb->len;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Ensure transmit function is called only in case th=
ere is at least
> + =A0 =A0 =A0 =A0* one port present.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (likely(!list_empty(&team->port_list) && team->mode_=
ops.transmit))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_success =3D team->mode_ops.transmit(=
team, skb);
> + =A0 =A0 =A0 if (tx_success) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct team_pcpu_stats *pcpu_stats;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pcpu_stats =3D this_cpu_ptr(team->pcpu_=
stats);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64_stats_update_begin(&pcpu_stats->syn=
cp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pcpu_stats->tx_packets++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pcpu_stats->tx_bytes +=3D len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64_stats_update_end(&pcpu_stats->syncp=
);
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 this_cpu_inc(team->pcpu_stats->tx_dropp=
ed);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return NETDEV_TX_OK;
> +}
> +
> +static void team_change_rx_flags(struct net_device *dev, int change)
> +{
> + =A0 =A0 =A0 struct team *team =3D netdev_priv(dev);
> + =A0 =A0 =A0 struct team_port *port;
> + =A0 =A0 =A0 int inc;
> +
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 list_for_each_entry_rcu(port, &team->port_list, list) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (change & IFF_PROMISC) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 inc =3D dev->flags & IF=
=46_PROMISC ? 1 : -1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_set_promiscuity(por=
t->dev, inc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (change & IFF_ALLMULTI) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 inc =3D dev->flags & IF=
=46_ALLMULTI ? 1 : -1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_set_allmulti(port->=
dev, inc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 rcu_read_unlock();
> +}
> +
> +static void team_set_rx_mode(struct net_device *dev)
> +{
> + =A0 =A0 =A0 struct team *team =3D netdev_priv(dev);
> + =A0 =A0 =A0 struct team_port *port;
> +
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 list_for_each_entry_rcu(port, &team->port_list, list) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_uc_sync(port->dev, dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_mc_sync(port->dev, dev);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 rcu_read_unlock();
> +}
> +
> +static int team_set_mac_address(struct net_device *dev, void *p)
> +{
> + =A0 =A0 =A0 struct team *team =3D netdev_priv(dev);
> + =A0 =A0 =A0 struct team_port *port;
> + =A0 =A0 =A0 struct sockaddr *addr =3D p;
> +
> + =A0 =A0 =A0 memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 list_for_each_entry_rcu(port, &team->port_list, list)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (team->mode_ops.port_change_mac)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 team->mode_ops.port_cha=
nge_mac(team, port);
> + =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int team_change_mtu(struct net_device *dev, int new_mtu)
> +{
> + =A0 =A0 =A0 struct team *team =3D netdev_priv(dev);
> + =A0 =A0 =A0 struct team_port *port;
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 list_for_each_entry_rcu(port, &team->port_list, list) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D dev_set_mtu(port->dev, new_mtu)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_err(dev, "Device=
 %s failed to change mtu",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
port->dev->name);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto unwind;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 rcu_read_unlock();
> +
> + =A0 =A0 =A0 dev->mtu =3D new_mtu;
> +
> + =A0 =A0 =A0 return 0;
> +
> +unwind:
> + =A0 =A0 =A0 list_for_each_entry_continue_reverse(port, &team->port_=
list, list)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_set_mtu(port->dev, dev->mtu);
> +
> + =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 return err;
> +}
> +
> +static struct rtnl_link_stats64 *
> +team_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *s=
tats)
> +{
> + =A0 =A0 =A0 struct team *team =3D netdev_priv(dev);
> + =A0 =A0 =A0 struct team_pcpu_stats *p;
> + =A0 =A0 =A0 u64 rx_packets, rx_bytes, rx_multicast, tx_packets, tx_=
bytes;
> + =A0 =A0 =A0 u32 rx_dropped =3D 0, tx_dropped =3D 0;
> + =A0 =A0 =A0 unsigned int start;
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 for_each_possible_cpu(i) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p =3D per_cpu_ptr(team->pcpu_stats, i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start =3D u64_stats_fet=
ch_begin_bh(&p->syncp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_packets =A0 =A0 =A0=3D=
 p->rx_packets;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_bytes =A0 =A0 =A0 =A0=
=3D p->rx_bytes;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_multicast =A0 =A0=3D=
 p->rx_multicast;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_packets =A0 =A0 =A0=3D=
 p->tx_packets;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_bytes =A0 =A0 =A0 =A0=
=3D p->tx_bytes;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } while (u64_stats_fetch_retry_bh(&p->s=
yncp, start));
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 stats->rx_packets =A0 =A0 =A0 +=3D rx_p=
ackets;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 stats->rx_bytes =A0 =A0 =A0 =A0 +=3D rx=
_bytes;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 stats->multicast =A0 =A0 =A0 =A0+=3D rx=
_multicast;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 stats->tx_packets =A0 =A0 =A0 +=3D tx_p=
ackets;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 stats->tx_bytes =A0 =A0 =A0 =A0 +=3D tx=
_bytes;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* rx_dropped & tx_dropped are u32, u=
pdated
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* without syncp protection.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_dropped =A0 =A0 =A0+=3D p->rx_droppe=
d;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_dropped =A0 =A0 =A0+=3D p->tx_droppe=
d;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 stats->rx_dropped =A0 =A0 =A0 =3D rx_dropped;
> + =A0 =A0 =A0 stats->tx_dropped =A0 =A0 =A0 =3D tx_dropped;
> + =A0 =A0 =A0 return stats;
> +}
> +
> +static void team_vlan_rx_add_vid(struct net_device *dev, uint16_t vi=
d)
> +{
> + =A0 =A0 =A0 struct team *team =3D netdev_priv(dev);
> + =A0 =A0 =A0 struct team_port *port;
> +
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 list_for_each_entry_rcu(port, &team->port_list, list) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct net_device_ops *ops =3D po=
rt->dev->netdev_ops;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ops->ndo_vlan_rx_add_vid(port->dev, vid=
);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 rcu_read_unlock();
> +}
> +
> +static void team_vlan_rx_kill_vid(struct net_device *dev, uint16_t v=
id)
> +{
> + =A0 =A0 =A0 struct team *team =3D netdev_priv(dev);
> + =A0 =A0 =A0 struct team_port *port;
> +
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 list_for_each_entry_rcu(port, &team->port_list, list) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct net_device_ops *ops =3D po=
rt->dev->netdev_ops;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ops->ndo_vlan_rx_kill_vid(port->dev, vi=
d);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 rcu_read_unlock();
> +}
> +
> +static int team_add_slave(struct net_device *dev, struct net_device =
*port_dev)
> +{
> + =A0 =A0 =A0 struct team *team =3D netdev_priv(dev);
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 spin_lock(&team->lock);
> + =A0 =A0 =A0 err =3D team_port_add(team, port_dev);
> + =A0 =A0 =A0 spin_unlock(&team->lock);
> + =A0 =A0 =A0 return err;
> +}
> +
> +static int team_del_slave(struct net_device *dev, struct net_device =
*port_dev)
> +{
> + =A0 =A0 =A0 struct team *team =3D netdev_priv(dev);
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 spin_lock(&team->lock);
> + =A0 =A0 =A0 err =3D team_port_del(team, port_dev);
> + =A0 =A0 =A0 spin_unlock(&team->lock);
> + =A0 =A0 =A0 return err;
> +}
> +
> +static const struct net_device_ops team_netdev_ops =3D {
> + =A0 =A0 =A0 .ndo_init =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D team_init,
> + =A0 =A0 =A0 .ndo_uninit =A0 =A0 =A0 =A0 =A0 =A0 =3D team_uninit,
> + =A0 =A0 =A0 .ndo_open =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D team_open,
> + =A0 =A0 =A0 .ndo_stop =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D team_close,
> + =A0 =A0 =A0 .ndo_start_xmit =A0 =A0 =A0 =A0 =3D team_xmit,
> + =A0 =A0 =A0 .ndo_change_rx_flags =A0 =A0=3D team_change_rx_flags,
> + =A0 =A0 =A0 .ndo_set_rx_mode =A0 =A0 =A0 =A0=3D team_set_rx_mode,
> + =A0 =A0 =A0 .ndo_set_mac_address =A0 =A0=3D team_set_mac_address,
> + =A0 =A0 =A0 .ndo_change_mtu =A0 =A0 =A0 =A0 =3D team_change_mtu,
> + =A0 =A0 =A0 .ndo_get_stats64 =A0 =A0 =A0 =A0=3D team_get_stats64,
> + =A0 =A0 =A0 .ndo_vlan_rx_add_vid =A0 =A0=3D team_vlan_rx_add_vid,
> + =A0 =A0 =A0 .ndo_vlan_rx_kill_vid =A0 =3D team_vlan_rx_kill_vid,
> + =A0 =A0 =A0 .ndo_add_slave =A0 =A0 =A0 =A0 =A0=3D team_add_slave,
> + =A0 =A0 =A0 .ndo_del_slave =A0 =A0 =A0 =A0 =A0=3D team_del_slave,
> +};
> +
> +
> +/***********************
> + * rt netlink interface
> + ***********************/
> +
> +static void team_setup(struct net_device *dev)
> +{
> + =A0 =A0 =A0 ether_setup(dev);
> +
> + =A0 =A0 =A0 dev->netdev_ops =3D &team_netdev_ops;
> + =A0 =A0 =A0 dev->destructor =3D team_destructor;
> + =A0 =A0 =A0 dev->tx_queue_len =3D 0;
> + =A0 =A0 =A0 dev->flags |=3D IFF_MULTICAST;
> + =A0 =A0 =A0 dev->priv_flags &=3D ~(IFF_XMIT_DST_RELEASE | IFF_TX_SK=
B_SHARING);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Indicate we support unicast address filtering. Tha=
t way core won't
> + =A0 =A0 =A0 =A0* bring us to promisc mode in case a unicast addr is=
 added.
> + =A0 =A0 =A0 =A0* Let this up to underlay drivers.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 dev->priv_flags |=3D IFF_UNICAST_FLT;
> +
> + =A0 =A0 =A0 dev->features |=3D NETIF_F_LLTX;
> + =A0 =A0 =A0 dev->features |=3D NETIF_F_GRO;
> + =A0 =A0 =A0 dev->hw_features =3D NETIF_F_HW_VLAN_TX |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NETIF_F_HW_VLAN_=
RX |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NETIF_F_HW_VLAN_=
=46ILTER;
> +
> + =A0 =A0 =A0 dev->features |=3D dev->hw_features;
> +}
> +
> +static int team_newlink(struct net *src_net, struct net_device *dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct nlattr *tb[], st=
ruct nlattr *data[])
> +{
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 if (tb[IFLA_ADDRESS] =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 random_ether_addr(dev->dev_addr);
> +
> + =A0 =A0 =A0 err =3D register_netdevice(dev);
> + =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int team_validate(struct nlattr *tb[], struct nlattr *data[])
> +{
> + =A0 =A0 =A0 if (tb[IFLA_ADDRESS]) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nla_len(tb[IFLA_ADDRESS]) !=3D ETH_=
ALEN)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!is_valid_ether_addr(nla_data(tb[IF=
LA_ADDRESS])))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EADDRNOTAVAIL;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static struct rtnl_link_ops team_link_ops __read_mostly =3D {
> + =A0 =A0 =A0 .kind =A0 =A0 =A0 =A0 =A0 =3D DRV_NAME,
> + =A0 =A0 =A0 .priv_size =A0 =A0 =A0=3D sizeof(struct team),
> + =A0 =A0 =A0 .setup =A0 =A0 =A0 =A0 =A0=3D team_setup,
> + =A0 =A0 =A0 .newlink =A0 =A0 =A0 =A0=3D team_newlink,
> + =A0 =A0 =A0 .validate =A0 =A0 =A0 =3D team_validate,
> +};
> +
> +
> +/***********************************
> + * Generic netlink custom interface
> + ***********************************/
> +
> +static struct genl_family team_nl_family =3D {
> + =A0 =A0 =A0 .id =A0 =A0 =A0 =A0 =A0 =A0 =3D GENL_ID_GENERATE,
> + =A0 =A0 =A0 .name =A0 =A0 =A0 =A0 =A0 =3D TEAM_GENL_NAME,
> + =A0 =A0 =A0 .version =A0 =A0 =A0 =A0=3D TEAM_GENL_VERSION,
> + =A0 =A0 =A0 .maxattr =A0 =A0 =A0 =A0=3D TEAM_ATTR_MAX,
> + =A0 =A0 =A0 .netnsok =A0 =A0 =A0 =A0=3D true,
> +};
> +
> +static const struct nla_policy team_nl_policy[TEAM_ATTR_MAX + 1] =3D=
 {
> + =A0 =A0 =A0 [TEAM_ATTR_UNSPEC] =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0=3D { .type =3D NLA_UNSPEC, },
> + =A0 =A0 =A0 [TEAM_ATTR_TEAM_IFINDEX] =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
=3D { .type =3D NLA_U32 },
> + =A0 =A0 =A0 [TEAM_ATTR_LIST_OPTION] =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =3D { .type =3D NLA_NESTED },
> + =A0 =A0 =A0 [TEAM_ATTR_LIST_PORT] =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =3D { .type =3D NLA_NESTED },
> +};
> +
> +static const struct nla_policy
> +team_nl_option_policy[TEAM_ATTR_OPTION_MAX + 1] =3D {
> + =A0 =A0 =A0 [TEAM_ATTR_OPTION_UNSPEC] =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D=
 { .type =3D NLA_UNSPEC, },
> + =A0 =A0 =A0 [TEAM_ATTR_OPTION_NAME] =3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .type =3D NLA_STRING,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .len =3D TEAM_STRING_MAX_LEN,
> + =A0 =A0 =A0 },
> + =A0 =A0 =A0 [TEAM_ATTR_OPTION_CHANGED] =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D=
 { .type =3D NLA_FLAG },
> + =A0 =A0 =A0 [TEAM_ATTR_OPTION_TYPE] =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =3D { .type =3D NLA_U8 },
> + =A0 =A0 =A0 [TEAM_ATTR_OPTION_DATA] =3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .type =3D NLA_BINARY,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .len =3D TEAM_STRING_MAX_LEN,
> + =A0 =A0 =A0 },
> +};
> +
> +static int team_nl_cmd_noop(struct sk_buff *skb, struct genl_info *i=
nfo)
> +{
> + =A0 =A0 =A0 struct sk_buff *msg;
> + =A0 =A0 =A0 void *hdr;
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 msg =3D nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
> + =A0 =A0 =A0 if (!msg)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 hdr =3D genlmsg_put(msg, info->snd_pid, info->snd_seq,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &team_nl_family, 0,=
 TEAM_CMD_NOOP);
> + =A0 =A0 =A0 if (IS_ERR(hdr)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D PTR_ERR(hdr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_msg_put;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 genlmsg_end(msg, hdr);
> +
> + =A0 =A0 =A0 return genlmsg_unicast(genl_info_net(info), msg, info->=
snd_pid);
> +
> +err_msg_put:
> + =A0 =A0 =A0 nlmsg_free(msg);
> +
> + =A0 =A0 =A0 return err;
> +}
> +
> +/*
> + * Netlink cmd functions should be locked by following two functions=
=2E
> + * To ensure team_uninit would not be called in between, hold rcu_re=
ad_lock
> + * all the time.
> + */
> +static struct team *team_nl_team_get(struct genl_info *info)
> +{
> + =A0 =A0 =A0 struct net *net =3D genl_info_net(info);
> + =A0 =A0 =A0 int ifindex;
> + =A0 =A0 =A0 struct net_device *dev;
> + =A0 =A0 =A0 struct team *team;
> +
> + =A0 =A0 =A0 if (!info->attrs[TEAM_ATTR_TEAM_IFINDEX])
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> +
> + =A0 =A0 =A0 ifindex =3D nla_get_u32(info->attrs[TEAM_ATTR_TEAM_IFIN=
DEX]);
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 dev =3D dev_get_by_index_rcu(net, ifindex);
> + =A0 =A0 =A0 if (!dev || dev->netdev_ops !=3D &team_netdev_ops) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 team =3D netdev_priv(dev);
> + =A0 =A0 =A0 spin_lock(&team->lock);
> + =A0 =A0 =A0 return team;
> +}
> +
> +static void team_nl_team_put(struct team *team)
> +{
> + =A0 =A0 =A0 spin_unlock(&team->lock);
> + =A0 =A0 =A0 rcu_read_unlock();
> +}
> +
> +static int team_nl_send_generic(struct genl_info *info, struct team =
*team,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int (*f=
ill_func)(struct sk_buff *skb,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct genl_info *info,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0int flags, struct team *team))
> +{
> + =A0 =A0 =A0 struct sk_buff *skb;
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 skb =3D nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
> + =A0 =A0 =A0 if (!skb)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 err =3D fill_func(skb, info, NLM_F_ACK, team);
> + =A0 =A0 =A0 if (err < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_fill;
> +
> + =A0 =A0 =A0 err =3D genlmsg_unicast(genl_info_net(info), skb, info-=
>snd_pid);
> + =A0 =A0 =A0 return err;
> +
> +err_fill:
> + =A0 =A0 =A0 nlmsg_free(skb);
> + =A0 =A0 =A0 return err;
> +}
> +
> +static int team_nl_fill_options_get_changed(struct sk_buff *skb,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 u32 pid, u32 seq, int flags,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 struct team *team,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 struct team_option *changed_option)
> +{
> + =A0 =A0 =A0 struct nlattr *option_list;
> + =A0 =A0 =A0 void *hdr;
> + =A0 =A0 =A0 struct team_option *option;
> +
> + =A0 =A0 =A0 hdr =3D genlmsg_put(skb, pid, seq, &team_nl_family, fla=
gs,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 TEAM_CMD_OPTIONS_GE=
T);
> + =A0 =A0 =A0 if (IS_ERR(hdr))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PTR_ERR(hdr);
> +
> + =A0 =A0 =A0 NLA_PUT_U32(skb, TEAM_ATTR_TEAM_IFINDEX, team->dev->ifi=
ndex);
> + =A0 =A0 =A0 option_list =3D nla_nest_start(skb, TEAM_ATTR_LIST_OPTI=
ON);
> + =A0 =A0 =A0 if (!option_list)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EMSGSIZE;
> +
> + =A0 =A0 =A0 list_for_each_entry(option, &team->option_list, list) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct nlattr *option_item;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 long arg;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 option_item =3D nla_nest_start(skb, TEA=
M_ATTR_ITEM_OPTION);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!option_item)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nla_put_failure;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 NLA_PUT_STRING(skb, TEAM_ATTR_OPTION_NA=
ME, option->name);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (option =3D=3D changed_option)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NLA_PUT_FLAG(skb, TEAM_=
ATTR_OPTION_CHANGED);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (option->type) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case TEAM_OPTION_TYPE_U32:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NLA_PUT_U8(skb, TEAM_AT=
TR_OPTION_TYPE, NLA_U32);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 team_option_get(team, o=
ption, &arg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NLA_PUT_U32(skb, TEAM_A=
TTR_OPTION_DATA, arg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case TEAM_OPTION_TYPE_STRING:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NLA_PUT_U8(skb, TEAM_AT=
TR_OPTION_TYPE, NLA_STRING);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 team_option_get(team, o=
ption, &arg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NLA_PUT_STRING(skb, TEA=
M_ATTR_OPTION_DATA,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0(char *) arg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nla_nest_end(skb, option_item);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 nla_nest_end(skb, option_list);
> + =A0 =A0 =A0 return genlmsg_end(skb, hdr);
> +
> +nla_put_failure:
> + =A0 =A0 =A0 genlmsg_cancel(skb, hdr);
> + =A0 =A0 =A0 return -EMSGSIZE;
> +}
> +
> +static int team_nl_fill_options_get(struct sk_buff *skb,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 struct genl_info *info, int flags,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 struct team *team)
> +{
> + =A0 =A0 =A0 return team_nl_fill_options_get_changed(skb, info->snd_=
pid,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 info->snd_seq, NLM_F_ACK,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 team, NULL);
> +}
> +
> +static int team_nl_cmd_options_get(struct sk_buff *skb, struct genl_=
info *info)
> +{
> + =A0 =A0 =A0 struct team *team;
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 team =3D team_nl_team_get(info);
> + =A0 =A0 =A0 if (!team)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> + =A0 =A0 =A0 err =3D team_nl_send_generic(info, team, team_nl_fill_o=
ptions_get);
> +
> + =A0 =A0 =A0 team_nl_team_put(team);
> +
> + =A0 =A0 =A0 return err;
> +}
> +
> +static int team_nl_cmd_options_set(struct sk_buff *skb, struct genl_=
info *info)
> +{
> + =A0 =A0 =A0 struct team *team;
> + =A0 =A0 =A0 int err =3D 0;
> + =A0 =A0 =A0 int i;
> + =A0 =A0 =A0 struct nlattr *nl_option;
> +
> + =A0 =A0 =A0 team =3D team_nl_team_get(info);
> + =A0 =A0 =A0 if (!team)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> + =A0 =A0 =A0 err =3D -EINVAL;
> + =A0 =A0 =A0 if (!info->attrs[TEAM_ATTR_LIST_OPTION]) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto team_put;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 nla_for_each_nested(nl_option, info->attrs[TEAM_ATTR_LI=
ST_OPTION], i) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct nlattr *mode_attrs[TEAM_ATTR_OPT=
ION_MAX + 1];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum team_option_type opt_type;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct team_option *option;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 char *opt_name;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool opt_found =3D false;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nla_type(nl_option) !=3D TEAM_ATTR_=
ITEM_OPTION) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto team_put;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D nla_parse_nested(mode_attrs, TE=
AM_ATTR_OPTION_MAX,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0nl_option, team_nl_option_policy);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto team_put;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mode_attrs[TEAM_ATTR_OPTION_NAME] =
||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !mode_attrs[TEAM_ATTR_OPTION_TY=
PE] ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !mode_attrs[TEAM_ATTR_OPTION_DA=
TA]) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto team_put;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (nla_get_u8(mode_attrs[TEAM_ATTR=
_OPTION_TYPE])) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case NLA_U32:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 opt_type =3D TEAM_OPTIO=
N_TYPE_U32;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case NLA_STRING:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 opt_type =3D TEAM_OPTIO=
N_TYPE_STRING;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto team_put;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 opt_name =3D nla_data(mode_attrs[TEAM_A=
TTR_OPTION_NAME]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_for_each_entry(option, &team->opti=
on_list, list) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 long arg;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct nlattr *opt_data=
_attr;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (option->type !=3D o=
pt_type ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 strcmp(option->=
name, opt_name))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continu=
e;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 opt_found =3D true;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 opt_data_attr =3D mode_=
attrs[TEAM_ATTR_OPTION_DATA];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (opt_type) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 case TEAM_OPTION_TYPE_U=
32:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 arg =3D=
 nla_get_u32(opt_data_attr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 case TEAM_OPTION_TYPE_S=
TRING:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 arg =3D=
 (long) nla_data(opt_data_attr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D team_option_set=
(team, option, &arg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto te=
am_put;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!opt_found) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -ENOENT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto team_put;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> +team_put:
> + =A0 =A0 =A0 team_nl_team_put(team);
> +
> + =A0 =A0 =A0 return err;
> +}
> +
> +static int team_nl_fill_port_list_get_changed(struct sk_buff *skb,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 u32 pid, u32 seq, int flags,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct team *team,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct team_port *changed_port)
> +{
> + =A0 =A0 =A0 struct nlattr *port_list;
> + =A0 =A0 =A0 void *hdr;
> + =A0 =A0 =A0 struct team_port *port;
> +
> + =A0 =A0 =A0 hdr =3D genlmsg_put(skb, pid, seq, &team_nl_family, fla=
gs,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 TEAM_CMD_PORT_LIST_=
GET);
> + =A0 =A0 =A0 if (IS_ERR(hdr))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PTR_ERR(hdr);
> +
> + =A0 =A0 =A0 NLA_PUT_U32(skb, TEAM_ATTR_TEAM_IFINDEX, team->dev->ifi=
ndex);
> + =A0 =A0 =A0 port_list =3D nla_nest_start(skb, TEAM_ATTR_LIST_PORT);
> + =A0 =A0 =A0 if (!port_list)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EMSGSIZE;
> +
> + =A0 =A0 =A0 list_for_each_entry_rcu(port, &team->port_list, list) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct nlattr *port_item;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 port_item =3D nla_nest_start(skb, TEAM_=
ATTR_ITEM_PORT);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!port_item)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nla_put_failure;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 NLA_PUT_U32(skb, TEAM_ATTR_PORT_IFINDEX=
, port->dev->ifindex);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (port =3D=3D changed_port)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NLA_PUT_FLAG(skb, TEAM_=
ATTR_PORT_CHANGED);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (port->linkup)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NLA_PUT_FLAG(skb, TEAM_=
ATTR_PORT_LINKUP);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 NLA_PUT_U32(skb, TEAM_ATTR_PORT_SPEED, =
port->speed);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 NLA_PUT_U8(skb, TEAM_ATTR_PORT_DUPLEX, =
port->duplex);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nla_nest_end(skb, port_item);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 nla_nest_end(skb, port_list);
> + =A0 =A0 =A0 return genlmsg_end(skb, hdr);
> +
> +nla_put_failure:
> + =A0 =A0 =A0 genlmsg_cancel(skb, hdr);
> + =A0 =A0 =A0 return -EMSGSIZE;
> +}
> +
> +static int team_nl_fill_port_list_get(struct sk_buff *skb,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct genl_info *info, int flags,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct team *team)
> +{
> + =A0 =A0 =A0 return team_nl_fill_port_list_get_changed(skb, info->sn=
d_pid,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 info->snd_seq, NLM_F_ACK,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 team, NULL);
> +}
> +
> +static int team_nl_cmd_port_list_get(struct sk_buff *skb,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0struct genl_info *info)
> +{
> + =A0 =A0 =A0 struct team *team;
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 team =3D team_nl_team_get(info);
> + =A0 =A0 =A0 if (!team)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> + =A0 =A0 =A0 err =3D team_nl_send_generic(info, team, team_nl_fill_p=
ort_list_get);
> +
> + =A0 =A0 =A0 team_nl_team_put(team);
> +
> + =A0 =A0 =A0 return err;
> +}
> +
> +static struct genl_ops team_nl_ops[] =3D {
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .cmd =3D TEAM_CMD_NOOP,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .doit =3D team_nl_cmd_noop,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .policy =3D team_nl_policy,
> + =A0 =A0 =A0 },
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .cmd =3D TEAM_CMD_OPTIONS_SET,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .doit =3D team_nl_cmd_options_set,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .policy =3D team_nl_policy,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .flags =3D GENL_ADMIN_PERM,
> + =A0 =A0 =A0 },
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .cmd =3D TEAM_CMD_OPTIONS_GET,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .doit =3D team_nl_cmd_options_get,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .policy =3D team_nl_policy,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .flags =3D GENL_ADMIN_PERM,
> + =A0 =A0 =A0 },
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .cmd =3D TEAM_CMD_PORT_LIST_GET,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .doit =3D team_nl_cmd_port_list_get,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .policy =3D team_nl_policy,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .flags =3D GENL_ADMIN_PERM,
> + =A0 =A0 =A0 },
> +};
> +
> +static struct genl_multicast_group team_change_event_mcgrp =3D {
> + =A0 =A0 =A0 .name =3D TEAM_GENL_CHANGE_EVENT_MC_GRP_NAME,
> +};
> +
> +static int team_nl_send_event_options_get(struct team *team,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 struct team_option *changed_option)
> +{
> + =A0 =A0 =A0 struct sk_buff *skb;
> + =A0 =A0 =A0 int err;
> + =A0 =A0 =A0 struct net *net =3D dev_net(team->dev);
> +
> + =A0 =A0 =A0 skb =3D nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
> + =A0 =A0 =A0 if (!skb)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 err =3D team_nl_fill_options_get_changed(skb, 0, 0, 0, =
team,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0changed_option);
> + =A0 =A0 =A0 if (err < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_fill;
> +
> + =A0 =A0 =A0 err =3D genlmsg_multicast_netns(net, skb, 0, team_chang=
e_event_mcgrp.id,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 GFP_KERNEL);
> + =A0 =A0 =A0 return err;
> +
> +err_fill:
> + =A0 =A0 =A0 nlmsg_free(skb);
> + =A0 =A0 =A0 return err;
> +}
> +
> +static int team_nl_send_event_port_list_get(struct team_port *port)
> +{
> + =A0 =A0 =A0 struct sk_buff *skb;
> + =A0 =A0 =A0 int err;
> + =A0 =A0 =A0 struct net *net =3D dev_net(port->team->dev);
> +
> + =A0 =A0 =A0 skb =3D nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
> + =A0 =A0 =A0 if (!skb)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 err =3D team_nl_fill_port_list_get_changed(skb, 0, 0, 0=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0port->team, port);
> + =A0 =A0 =A0 if (err < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_fill;
> +
> + =A0 =A0 =A0 err =3D genlmsg_multicast_netns(net, skb, 0, team_chang=
e_event_mcgrp.id,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 GFP_KERNEL);
> + =A0 =A0 =A0 return err;
> +
> +err_fill:
> + =A0 =A0 =A0 nlmsg_free(skb);
> + =A0 =A0 =A0 return err;
> +}
> +
> +static int team_nl_init(void)
> +{
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 err =3D genl_register_family_with_ops(&team_nl_family, =
team_nl_ops,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 ARRAY_SIZE(team_nl_ops));
> + =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> +
> + =A0 =A0 =A0 err =3D genl_register_mc_group(&team_nl_family, &team_c=
hange_event_mcgrp);
> + =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_change_event_grp_reg;
> +
> + =A0 =A0 =A0 return 0;
> +
> +err_change_event_grp_reg:
> + =A0 =A0 =A0 genl_unregister_family(&team_nl_family);
> +
> + =A0 =A0 =A0 return err;
> +}
> +
> +static void team_nl_fini(void)
> +{
> + =A0 =A0 =A0 genl_unregister_family(&team_nl_family);
> +}
> +
> +
> +/******************
> + * Change checkers
> + ******************/
> +
> +static void __team_options_change_check(struct team *team,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 struct team_option *changed_option)
> +{
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 err =3D team_nl_send_event_options_get(team, changed_op=
tion);
> + =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_warn(team->dev, "Failed to send =
options change via netlink\n");
> +}
> +
> +/* rtnl lock is held */
> +static void __team_port_change_check(struct team_port *port, bool li=
nkup)
> +{
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 if (port->linkup =3D=3D linkup)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 port->linkup =3D linkup;
> + =A0 =A0 =A0 if (linkup) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ethtool_cmd ecmd;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D __ethtool_get_settings(port->de=
v, &ecmd);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 port->speed =3D ethtool=
_cmd_speed(&ecmd);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 port->duplex =3D ecmd.d=
uplex;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto send_event;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 port->speed =3D 0;
> + =A0 =A0 =A0 port->duplex =3D 0;
> +
> +send_event:
> + =A0 =A0 =A0 err =3D team_nl_send_event_port_list_get(port);
> + =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_warn(port->team->dev, "Failed to=
 send port change of device %s via netlink\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 port->dev->name=
);
> +
> +}
> +
> +static void team_port_change_check(struct team_port *port, bool link=
up)
> +{
> + =A0 =A0 =A0 struct team *team =3D port->team;
> +
> + =A0 =A0 =A0 spin_lock(&team->lock);
> + =A0 =A0 =A0 __team_port_change_check(port, linkup);
> + =A0 =A0 =A0 spin_unlock(&team->lock);
> +}
> +
> +/************************************
> + * Net device notifier event handler
> + ************************************/
> +
> +static int team_device_event(struct notifier_block *unused,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned lon=
g event, void *ptr)
> +{
> + =A0 =A0 =A0 struct net_device *dev =3D (struct net_device *) ptr;
> + =A0 =A0 =A0 struct team_port *port;
> +
> + =A0 =A0 =A0 port =3D team_port_get_rtnl(dev);
> + =A0 =A0 =A0 if (!port)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NOTIFY_DONE;
> +
> + =A0 =A0 =A0 switch (event) {
> + =A0 =A0 =A0 case NETDEV_UP:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (netif_carrier_ok(dev))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 team_port_change_check(=
port, true);
> + =A0 =A0 =A0 case NETDEV_DOWN:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 team_port_change_check(port, false);
> + =A0 =A0 =A0 case NETDEV_CHANGE:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (netif_running(port->dev))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 team_port_change_check(=
port,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0!!netif_carrier_ok(port->dev));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 case NETDEV_UNREGISTER:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 team_del_slave(port->team->dev, dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 case NETDEV_FEAT_CHANGE:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 team_compute_features(port->team);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 case NETDEV_CHANGEMTU:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Forbid to change mtu of underlaying =
device */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NOTIFY_BAD;
> + =A0 =A0 =A0 case NETDEV_CHANGEADDR:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Forbid to change addr of underlaying=
 device */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NOTIFY_BAD;
> + =A0 =A0 =A0 case NETDEV_PRE_TYPE_CHANGE:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Forbid to change type of underlaying=
 device */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NOTIFY_BAD;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return NOTIFY_DONE;
> +}
> +
> +static struct notifier_block team_notifier_block __read_mostly =3D {
> + =A0 =A0 =A0 .notifier_call =3D team_device_event,
> +};
> +
> +
> +/***********************
> + * Module init and exit
> + ***********************/
> +
> +static int __init team_module_init(void)
> +{
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 register_netdevice_notifier(&team_notifier_block);
> +
> + =A0 =A0 =A0 err =3D rtnl_link_register(&team_link_ops);
> + =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_rtln_reg;
> +
> + =A0 =A0 =A0 err =3D team_nl_init();
> + =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_nl_init;
> +
> + =A0 =A0 =A0 return 0;
> +
> +err_nl_init:
> + =A0 =A0 =A0 rtnl_link_unregister(&team_link_ops);
> +
> +err_rtln_reg:
> + =A0 =A0 =A0 unregister_netdevice_notifier(&team_notifier_block);
> +
> + =A0 =A0 =A0 return err;
> +}
> +
> +static void __exit team_module_exit(void)
> +{
> + =A0 =A0 =A0 team_nl_fini();
> + =A0 =A0 =A0 rtnl_link_unregister(&team_link_ops);
> + =A0 =A0 =A0 unregister_netdevice_notifier(&team_notifier_block);
> +}
> +
> +module_init(team_module_init);
> +module_exit(team_module_exit);
> +
> +MODULE_LICENSE("GPL v2");
> +MODULE_AUTHOR("Jiri Pirko <jpirko@redhat.com>");
> +MODULE_DESCRIPTION("Ethernet team device driver");
> +MODULE_ALIAS_RTNL_LINK(DRV_NAME);
> diff --git a/drivers/net/team/team_mode_activebackup.c b/drivers/net/=
team/team_mode_activebackup.c
> new file mode 100644
> index 0000000..1aa2bfb
> --- /dev/null
> +++ b/drivers/net/team/team_mode_activebackup.c
> @@ -0,0 +1,152 @@
> +/*
> + * net/drivers/team/team_mode_activebackup.c - Active-backup mode fo=
r team
> + * Copyright (c) 2011 Jiri Pirko <jpirko@redhat.com>
> + *
> + * This program is free software; you can redistribute it and/or mod=
ify
> + * it under the terms of the GNU General Public License as published=
 by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/errno.h>
> +#include <linux/netdevice.h>
> +#include <net/rtnetlink.h>
> +#include <linux/if_team.h>
> +
> +struct ab_priv {
> + =A0 =A0 =A0 struct team_port __rcu *active_port;
> +};
> +
> +static struct ab_priv *ab_priv(struct team *team)
> +{
> + =A0 =A0 =A0 return (struct ab_priv *) &team->mode_priv;
> +}
> +
> +static rx_handler_result_t ab_receive(struct team *team, struct team=
_port *port,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct sk_buff *skb) {
> + =A0 =A0 =A0 struct team_port *active_port;
> +
> + =A0 =A0 =A0 active_port =3D rcu_dereference(ab_priv(team)->active_p=
ort);
> + =A0 =A0 =A0 if (active_port !=3D port)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return RX_HANDLER_EXACT;
> + =A0 =A0 =A0 return RX_HANDLER_ANOTHER;
> +}
> +
> +static bool ab_transmit(struct team *team, struct sk_buff *skb)
> +{
> + =A0 =A0 =A0 struct team_port *active_port;
> +
> + =A0 =A0 =A0 active_port =3D rcu_dereference(ab_priv(team)->active_p=
ort);
> + =A0 =A0 =A0 if (unlikely(!active_port))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto drop;
> + =A0 =A0 =A0 skb->dev =3D active_port->dev;
> + =A0 =A0 =A0 if (dev_queue_xmit(skb))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> + =A0 =A0 =A0 return true;
> +
> +drop:
> + =A0 =A0 =A0 dev_kfree_skb(skb);
> + =A0 =A0 =A0 return false;
> +}
> +
> +static void ab_port_leave(struct team *team, struct team_port *port)
> +{
> + =A0 =A0 =A0 if (ab_priv(team)->active_port =3D=3D port)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_assign_pointer(ab_priv(team)->activ=
e_port, NULL);
> +}
> +
> +static void ab_port_change_mac(struct team *team, struct team_port *=
port)
> +{
> + =A0 =A0 =A0 if (ab_priv(team)->active_port =3D=3D port)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 team_port_set_team_mac(port);
> +}
> +
> +static int ab_active_port_get(struct team *team, void *arg)
> +{
> + =A0 =A0 =A0 u32 *ifindex =3D arg;
> +
> + =A0 =A0 =A0 *ifindex =3D 0;
> + =A0 =A0 =A0 if (ab_priv(team)->active_port)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *ifindex =3D ab_priv(team)->active_port=
->dev->ifindex;
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int ab_active_port_set(struct team *team, void *arg)
> +{
> + =A0 =A0 =A0 u32 *ifindex =3D arg;
> + =A0 =A0 =A0 struct team_port *port;
> +
> + =A0 =A0 =A0 list_for_each_entry_rcu(port, &team->port_list, list) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (port->dev->ifindex =3D=3D *ifindex)=
 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct team_port *ac_po=
rt =3D ab_priv(team)->active_port;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* rtnl_lock needs to b=
e held when setting macs */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rtnl_lock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ac_port)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 team_po=
rt_set_orig_mac(ac_port);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_assign_pointer(ab_p=
riv(team)->active_port, port);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 team_port_set_team_mac(=
port);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rtnl_unlock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return -ENOENT;
> +}
> +
> +static struct team_option ab_options[] =3D {
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "activeport",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .type =3D TEAM_OPTION_TYPE_U32,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .getter =3D ab_active_port_get,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .setter =3D ab_active_port_set,
> + =A0 =A0 =A0 },
> +};
> +
> +int ab_init(struct team *team)
> +{
> + =A0 =A0 =A0 team_options_register(team, ab_options, ARRAY_SIZE(ab_o=
ptions));
> + =A0 =A0 =A0 return 0;
> +}
> +
> +void ab_exit(struct team *team)
> +{
> + =A0 =A0 =A0 team_options_unregister(team, ab_options, ARRAY_SIZE(ab=
_options));
> +}
> +
> +static const struct team_mode_ops ab_mode_ops =3D {
> + =A0 =A0 =A0 .init =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D ab_init,
> + =A0 =A0 =A0 .exit =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D ab_exit,
> + =A0 =A0 =A0 .receive =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D ab_receive,
> + =A0 =A0 =A0 .transmit =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D ab_transmit,
> + =A0 =A0 =A0 .port_leave =A0 =A0 =A0 =A0 =A0 =A0 =3D ab_port_leave,
> + =A0 =A0 =A0 .port_change_mac =A0 =A0 =A0 =A0=3D ab_port_change_mac,
> +};
> +
> +static struct team_mode ab_mode =3D {
> + =A0 =A0 =A0 .kind =A0 =A0 =A0 =A0 =A0 =3D "activebackup",
> + =A0 =A0 =A0 .owner =A0 =A0 =A0 =A0 =A0=3D THIS_MODULE,
> + =A0 =A0 =A0 .priv_size =A0 =A0 =A0=3D sizeof(struct ab_priv),
> + =A0 =A0 =A0 .ops =A0 =A0 =A0 =A0 =A0 =A0=3D &ab_mode_ops,
> +};
> +
> +static int __init ab_init_module(void)
> +{
> + =A0 =A0 =A0 return team_mode_register(&ab_mode);
> +}
> +
> +static void __exit ab_cleanup_module(void)
> +{
> + =A0 =A0 =A0 team_mode_unregister(&ab_mode);
> +}
> +
> +module_init(ab_init_module);
> +module_exit(ab_cleanup_module);
> +
> +MODULE_LICENSE("GPL v2");
> +MODULE_AUTHOR("Jiri Pirko <jpirko@redhat.com>");
> +MODULE_DESCRIPTION("Active-backup mode for team");
> +MODULE_ALIAS("team-mode-activebackup");
> diff --git a/drivers/net/team/team_mode_roundrobin.c b/drivers/net/te=
am/team_mode_roundrobin.c
> new file mode 100644
> index 0000000..0374052
> --- /dev/null
> +++ b/drivers/net/team/team_mode_roundrobin.c
> @@ -0,0 +1,107 @@
> +/*
> + * net/drivers/team/team_mode_roundrobin.c - Round-robin mode for te=
am
> + * Copyright (c) 2011 Jiri Pirko <jpirko@redhat.com>
> + *
> + * This program is free software; you can redistribute it and/or mod=
ify
> + * it under the terms of the GNU General Public License as published=
 by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/errno.h>
> +#include <linux/netdevice.h>
> +#include <linux/if_team.h>
> +
> +struct rr_priv {
> + =A0 =A0 =A0 unsigned int sent_packets;
> +};
> +
> +static struct rr_priv *rr_priv(struct team *team)
> +{
> + =A0 =A0 =A0 return (struct rr_priv *) &team->mode_priv;
> +}
> +
> +static struct team_port *__get_first_port_up(struct team *team,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0struct team_port *port)
> +{
> + =A0 =A0 =A0 struct team_port *cur;
> +
> + =A0 =A0 =A0 if (port->linkup)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return port;
> + =A0 =A0 =A0 cur =3D port;
> + =A0 =A0 =A0 list_for_each_entry_continue_rcu(cur, &team->port_list,=
 list)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cur->linkup)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return cur;
> + =A0 =A0 =A0 list_for_each_entry_rcu(cur, &team->port_list, list) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cur =3D=3D port)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cur->linkup)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return cur;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return NULL;
> +}
> +
> +static bool rr_transmit(struct team *team, struct sk_buff *skb)
> +{
> + =A0 =A0 =A0 struct team_port *port;
> + =A0 =A0 =A0 int port_index;
> +
> + =A0 =A0 =A0 port_index =3D rr_priv(team)->sent_packets++ % team->po=
rt_count;
> + =A0 =A0 =A0 port =3D team_get_port_by_index_rcu(team, port_index);
> + =A0 =A0 =A0 port =3D __get_first_port_up(team, port);
> + =A0 =A0 =A0 if (unlikely(!port))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto drop;
> + =A0 =A0 =A0 skb->dev =3D port->dev;
> + =A0 =A0 =A0 if (dev_queue_xmit(skb))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> + =A0 =A0 =A0 return true;
> +
> +drop:
> + =A0 =A0 =A0 dev_kfree_skb(skb);
> + =A0 =A0 =A0 return false;
> +}
> +
> +static int rr_port_enter(struct team *team, struct team_port *port)
> +{
> + =A0 =A0 =A0 return team_port_set_team_mac(port);
> +}
> +
> +static void rr_port_change_mac(struct team *team, struct team_port *=
port)
> +{
> + =A0 =A0 =A0 team_port_set_team_mac(port);
> +}
> +
> +static const struct team_mode_ops rr_mode_ops =3D {
> + =A0 =A0 =A0 .transmit =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D rr_transmit,
> + =A0 =A0 =A0 .port_enter =A0 =A0 =A0 =A0 =A0 =A0 =3D rr_port_enter,
> + =A0 =A0 =A0 .port_change_mac =A0 =A0 =A0 =A0=3D rr_port_change_mac,
> +};
> +
> +static struct team_mode rr_mode =3D {
> + =A0 =A0 =A0 .kind =A0 =A0 =A0 =A0 =A0 =3D "roundrobin",
> + =A0 =A0 =A0 .owner =A0 =A0 =A0 =A0 =A0=3D THIS_MODULE,
> + =A0 =A0 =A0 .priv_size =A0 =A0 =A0=3D sizeof(struct rr_priv),
> + =A0 =A0 =A0 .ops =A0 =A0 =A0 =A0 =A0 =A0=3D &rr_mode_ops,
> +};
> +
> +static int __init rr_init_module(void)
> +{
> + =A0 =A0 =A0 return team_mode_register(&rr_mode);
> +}
> +
> +static void __exit rr_cleanup_module(void)
> +{
> + =A0 =A0 =A0 team_mode_unregister(&rr_mode);
> +}
> +
> +module_init(rr_init_module);
> +module_exit(rr_cleanup_module);
> +
> +MODULE_LICENSE("GPL v2");
> +MODULE_AUTHOR("Jiri Pirko <jpirko@redhat.com>");
> +MODULE_DESCRIPTION("Round-robin mode for team");
> +MODULE_ALIAS("team-mode-roundrobin");
> diff --git a/include/linux/Kbuild b/include/linux/Kbuild
> index 619b565..0b091b3 100644
> --- a/include/linux/Kbuild
> +++ b/include/linux/Kbuild
> @@ -185,6 +185,7 @@ header-y +=3D if_pppol2tp.h
> =A0header-y +=3D if_pppox.h
> =A0header-y +=3D if_slip.h
> =A0header-y +=3D if_strip.h
> +header-y +=3D if_team.h
> =A0header-y +=3D if_tr.h
> =A0header-y +=3D if_tun.h
> =A0header-y +=3D if_tunnel.h
> diff --git a/include/linux/if.h b/include/linux/if.h
> index db20bd4..06b6ef6 100644
> --- a/include/linux/if.h
> +++ b/include/linux/if.h
> @@ -79,6 +79,7 @@
> =A0#define IFF_TX_SKB_SHARING =A0 =A0 0x10000 /* The interface suppor=
ts sharing
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 * skbs on transmit */
> =A0#define IFF_UNICAST_FLT =A0 =A0 =A0 =A00x20000 =A0 =A0 =A0 =A0 /* =
Supports unicast filtering =A0 */
> +#define IFF_TEAM_PORT =A00x40000 =A0 =A0 =A0 =A0 /* device used as t=
eam port */
>
> =A0#define IF_GET_IFACE =A0 0x0001 =A0 =A0 =A0 =A0 =A0/* for querying=
 only */
> =A0#define IF_GET_PROTO =A0 0x0002
> diff --git a/include/linux/if_team.h b/include/linux/if_team.h
> new file mode 100644
> index 0000000..21581a7
> --- /dev/null
> +++ b/include/linux/if_team.h
> @@ -0,0 +1,233 @@
> +/*
> + * include/linux/if_team.h - Network team device driver header
> + * Copyright (c) 2011 Jiri Pirko <jpirko@redhat.com>
> + *
> + * This program is free software; you can redistribute it and/or mod=
ify
> + * it under the terms of the GNU General Public License as published=
 by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#ifndef _LINUX_IF_TEAM_H_
> +#define _LINUX_IF_TEAM_H_
> +
> +#ifdef __KERNEL__
> +
> +struct team_pcpu_stats {
> + =A0 =A0 =A0 u64 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_packets;
> + =A0 =A0 =A0 u64 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_bytes;
> + =A0 =A0 =A0 u64 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_multicas=
t;
> + =A0 =A0 =A0 u64 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_packets;
> + =A0 =A0 =A0 u64 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_bytes;
> + =A0 =A0 =A0 struct u64_stats_sync =A0 syncp;
> + =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_dropped;
> + =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_dropped;
> +};
> +
> +struct team;
> +
> +struct team_port {
> + =A0 =A0 =A0 struct net_device *dev;
> + =A0 =A0 =A0 struct hlist_node hlist; /* node in hash list */
> + =A0 =A0 =A0 struct list_head list; /* node in ordinary list */
> + =A0 =A0 =A0 struct team *team;
> + =A0 =A0 =A0 int index;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* A place for storing original values of the device =
before it
> + =A0 =A0 =A0 =A0* become a port.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 struct {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned char dev_addr[MAX_ADDR_LEN];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int mtu;
> + =A0 =A0 =A0 } orig;
> +
> + =A0 =A0 =A0 bool linkup;
> + =A0 =A0 =A0 u32 speed;
> + =A0 =A0 =A0 u8 duplex;
> +
> + =A0 =A0 =A0 struct rcu_head rcu;
> +};
> +
> +struct team_mode_ops {
> + =A0 =A0 =A0 int (*init)(struct team *team);
> + =A0 =A0 =A0 void (*exit)(struct team *team);
> + =A0 =A0 =A0 rx_handler_result_t (*receive)(struct team *team,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0struct team_port *port,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0struct sk_buff *skb);
> + =A0 =A0 =A0 bool (*transmit)(struct team *team, struct sk_buff *skb=
);
> + =A0 =A0 =A0 int (*port_enter)(struct team *team, struct team_port *=
port);
> + =A0 =A0 =A0 void (*port_leave)(struct team *team, struct team_port =
*port);
> + =A0 =A0 =A0 void (*port_change_mac)(struct team *team, struct team_=
port *port);
> +};
> +
> +enum team_option_type {
> + =A0 =A0 =A0 TEAM_OPTION_TYPE_U32,
> + =A0 =A0 =A0 TEAM_OPTION_TYPE_STRING,
> +};
> +
> +struct team_option {
> + =A0 =A0 =A0 struct list_head list;
> + =A0 =A0 =A0 const char *name;
> + =A0 =A0 =A0 enum team_option_type type;
> + =A0 =A0 =A0 int (*getter)(struct team *team, void *arg);
> + =A0 =A0 =A0 int (*setter)(struct team *team, void *arg);
> +};
> +
> +struct team_mode {
> + =A0 =A0 =A0 struct list_head list;
> + =A0 =A0 =A0 const char *kind;
> + =A0 =A0 =A0 struct module *owner;
> + =A0 =A0 =A0 size_t priv_size;
> + =A0 =A0 =A0 const struct team_mode_ops *ops;
> +};
> +
> +#define TEAM_MODE_PRIV_LONGS 4
> +#define TEAM_MODE_PRIV_SIZE (sizeof(long) * TEAM_MODE_PRIV_LONGS)
> +
> +struct team {
> + =A0 =A0 =A0 struct net_device *dev; /* associated netdevice */
> + =A0 =A0 =A0 struct team_pcpu_stats __percpu *pcpu_stats;
> +
> + =A0 =A0 =A0 spinlock_t lock; /* used for overall locking, e.g. port=
 lists write */
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* port lists with port count
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 int port_count;
> + =A0 =A0 =A0 struct hlist_head *port_hlist;
> + =A0 =A0 =A0 struct list_head port_list;
> +
> + =A0 =A0 =A0 struct list_head option_list;
> +
> + =A0 =A0 =A0 const char *mode_kind;
> + =A0 =A0 =A0 struct team_mode_ops mode_ops;
> + =A0 =A0 =A0 long mode_priv[TEAM_MODE_PRIV_LONGS];
> +};
> +
> +#define TEAM_PORT_HASHBITS 4
> +#define TEAM_PORT_HASHENTRIES (1 << TEAM_PORT_HASHBITS)
> +
> +static inline struct hlist_head *
> +team_port_index_hash(const struct team *team,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int port_index)
> +{
> + =A0 =A0 =A0 return &team->port_hlist[port_index & (TEAM_PORT_HASHEN=
TRIES - 1)];
> +}
> +
> +static inline struct team_port *
> +team_get_port_by_index_rcu(const struct team *team,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int port_index)
> +{
> + =A0 =A0 =A0 struct hlist_node *p;
> + =A0 =A0 =A0 struct team_port *port;
> + =A0 =A0 =A0 struct hlist_head *head =3D team_port_index_hash(team, =
port_index);
> +
> + =A0 =A0 =A0 hlist_for_each_entry_rcu(port, p, head, hlist)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (port->index =3D=3D port_index)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return port;
> + =A0 =A0 =A0 return NULL;
> +}
> +
> +extern int team_port_set_orig_mac(struct team_port *port);
> +extern int team_port_set_team_mac(struct team_port *port);
> +extern void team_options_register(struct team *team,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 str=
uct team_option *option,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 siz=
e_t option_count);
> +extern void team_options_unregister(struct team *team,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 struct team_option *option,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 size_t option_count);
> +extern int team_mode_register(struct team_mode *mode);
> +extern int team_mode_unregister(struct team_mode *mode);
> +
> +#endif /* __KERNEL__ */
> +
> +#define TEAM_STRING_MAX_LEN 32
> +
> +/**********************************
> + * NETLINK_GENERIC netlink family.
> + **********************************/
> +
> +enum {
> + =A0 =A0 =A0 TEAM_CMD_NOOP,
> + =A0 =A0 =A0 TEAM_CMD_OPTIONS_SET,
> + =A0 =A0 =A0 TEAM_CMD_OPTIONS_GET,
> + =A0 =A0 =A0 TEAM_CMD_PORT_LIST_GET,
> +
> + =A0 =A0 =A0 __TEAM_CMD_MAX,
> + =A0 =A0 =A0 TEAM_CMD_MAX =3D (__TEAM_CMD_MAX - 1),
> +};
> +
> +enum {
> + =A0 =A0 =A0 TEAM_ATTR_UNSPEC,
> + =A0 =A0 =A0 TEAM_ATTR_TEAM_IFINDEX, =A0 =A0 =A0 =A0 /* u32 */
> + =A0 =A0 =A0 TEAM_ATTR_LIST_OPTION, =A0 =A0 =A0 =A0 =A0/* nest */
> + =A0 =A0 =A0 TEAM_ATTR_LIST_PORT, =A0 =A0 =A0 =A0 =A0 =A0/* nest */
> +
> + =A0 =A0 =A0 __TEAM_ATTR_MAX,
> + =A0 =A0 =A0 TEAM_ATTR_MAX =3D __TEAM_ATTR_MAX - 1,
> +};
> +
> +/* Nested layout of get/set msg:
> + *
> + * =A0 =A0 [TEAM_ATTR_LIST_OPTION]
> + * =A0 =A0 =A0 =A0 =A0 =A0 [TEAM_ATTR_ITEM_OPTION]
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 [TEAM_ATTR_OPTION_*], ...
> + * =A0 =A0 =A0 =A0 =A0 =A0 [TEAM_ATTR_ITEM_OPTION]
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 [TEAM_ATTR_OPTION_*], ...
> + * =A0 =A0 =A0 =A0 =A0 =A0 ...
> + * =A0 =A0 [TEAM_ATTR_LIST_PORT]
> + * =A0 =A0 =A0 =A0 =A0 =A0 [TEAM_ATTR_ITEM_PORT]
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 [TEAM_ATTR_PORT_*], ...
> + * =A0 =A0 =A0 =A0 =A0 =A0 [TEAM_ATTR_ITEM_PORT]
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 [TEAM_ATTR_PORT_*], ...
> + * =A0 =A0 =A0 =A0 =A0 =A0 ...
> + */
> +
> +enum {
> + =A0 =A0 =A0 TEAM_ATTR_ITEM_OPTION_UNSPEC,
> + =A0 =A0 =A0 TEAM_ATTR_ITEM_OPTION, =A0 =A0 =A0 =A0 =A0/* nest */
> +
> + =A0 =A0 =A0 __TEAM_ATTR_ITEM_OPTION_MAX,
> + =A0 =A0 =A0 TEAM_ATTR_ITEM_OPTION_MAX =3D __TEAM_ATTR_ITEM_OPTION_M=
AX - 1,
> +};
> +
> +enum {
> + =A0 =A0 =A0 TEAM_ATTR_OPTION_UNSPEC,
> + =A0 =A0 =A0 TEAM_ATTR_OPTION_NAME, =A0 =A0 =A0 =A0 =A0/* string */
> + =A0 =A0 =A0 TEAM_ATTR_OPTION_CHANGED, =A0 =A0 =A0 /* flag */
> + =A0 =A0 =A0 TEAM_ATTR_OPTION_TYPE, =A0 =A0 =A0 =A0 =A0/* u8 */
> + =A0 =A0 =A0 TEAM_ATTR_OPTION_DATA, =A0 =A0 =A0 =A0 =A0/* dynamic */
> +
> + =A0 =A0 =A0 __TEAM_ATTR_OPTION_MAX,
> + =A0 =A0 =A0 TEAM_ATTR_OPTION_MAX =3D __TEAM_ATTR_OPTION_MAX - 1,
> +};
> +
> +enum {
> + =A0 =A0 =A0 TEAM_ATTR_ITEM_PORT_UNSPEC,
> + =A0 =A0 =A0 TEAM_ATTR_ITEM_PORT, =A0 =A0 =A0 =A0 =A0 =A0/* nest */
> +
> + =A0 =A0 =A0 __TEAM_ATTR_ITEM_PORT_MAX,
> + =A0 =A0 =A0 TEAM_ATTR_ITEM_PORT_MAX =3D __TEAM_ATTR_ITEM_PORT_MAX -=
 1,
> +};
> +
> +enum {
> + =A0 =A0 =A0 TEAM_ATTR_PORT_UNSPEC,
> + =A0 =A0 =A0 TEAM_ATTR_PORT_IFINDEX, =A0 =A0 =A0 =A0 /* u32 */
> + =A0 =A0 =A0 TEAM_ATTR_PORT_CHANGED, =A0 =A0 =A0 =A0 /* flag */
> + =A0 =A0 =A0 TEAM_ATTR_PORT_LINKUP, =A0 =A0 =A0 =A0 =A0/* flag */
> + =A0 =A0 =A0 TEAM_ATTR_PORT_SPEED, =A0 =A0 =A0 =A0 =A0 /* u32 */
> + =A0 =A0 =A0 TEAM_ATTR_PORT_DUPLEX, =A0 =A0 =A0 =A0 =A0/* u8 */
> +
> + =A0 =A0 =A0 __TEAM_ATTR_PORT_MAX,
> + =A0 =A0 =A0 TEAM_ATTR_PORT_MAX =3D __TEAM_ATTR_PORT_MAX - 1,
> +};
> +
> +/*
> + * NETLINK_GENERIC related info
> + */
> +#define TEAM_GENL_NAME "team"
> +#define TEAM_GENL_VERSION 0x1
> +#define TEAM_GENL_CHANGE_EVENT_MC_GRP_NAME "change_event"
> +
> +#endif /* _LINUX_IF_TEAM_H_ */
> --
> 1.7.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
