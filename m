From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 00/10] introduce rocker switch driver with
 hardware accelerated datapath api - phase 1: bridge fdb offload
Date: Sun, 09 Nov 2014 22:31:39 -0500
Message-ID: <5460319B.2010605@mojatatu.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:64161 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbaKJDbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2014 22:31:45 -0500
Received: by mail-ig0-f176.google.com with SMTP id l13so17204499iga.9
        for <netdev@vger.kernel.org>; Sun, 09 Nov 2014 19:31:44 -0800 (PST)
In-Reply-To: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri,

I am hoping you have considered what Ben Lahaise's, John Fastabend's,
and Roopa's patches after all those discussions and
meetings we have had (in which you promised you will merge patches
in). I am not seeing much of that here or mention of anything of that
sort.
At least please get their sign on - this  is such an important piece of
new work that you should make sure you get consensus.
Otherwise we are back to square one and everyone is going their way with
their patches;

Ben/Roopa/John - please issue either a signed-off as well
if you agree with this approach otherwise i am hoping none of these
patches are merged in.

I will look at the patches and comment.

cheers,
jamal

On 11/09/14 05:51, Jiri Pirko wrote:
> Hi all.
>
> This patchset is just the first phase of switch and switch-ish device
> support api in kernel. Note that the api will extend (our complete work
> can be pulled from https://github.com/jpirko/net-next-rocker).
>
> So what this patchset includes:
> - introduce switchdev api for implementing switch drivers (so far
>    only linux bridge fdb offload is covered)
> - introduce rocker switch driver which implements switchdev api
>
> As to the discussion if there is need to have specific class of device
> representing the switch itself, so far we found no need to introduce that.
> But we are generally ok with the idea and when the time comes and it will
> be needed, it can be easily introduced without any disturbance.
>
> This patchset introduces switch id export through rtnetlink and sysfs,
> which is similar to what we have for port id in SR-IOV. I will send iproute2
> patchset for showing the switch id for port netdevs once this is applied.
>
> For detailed description, please see individual patches.
>
> v1->v2:
> - addressed all DaveM's comments
>
> Jiri Pirko (5):
>    net: rename netdev_phys_port_id to more generic name
>    net: introduce generic switch devices support
>    rtnl: expose physical switch id for particular device
>    net-sysfs: expose physical switch id for particular device
>    rocker: introduce rocker switch driver
>
> Scott Feldman (5):
>    bridge: introduce fdb offloading via switchdev
>    bridge: call netdev_sw_port_stp_update when bridge port STP status
>      changes
>    bridge: add API to notify bridge driver of learned FBD on offloaded
>      device
>    rocker: implement rocker ofdpa flow table manipulation
>    rocker: implement L2 bridge offloading
>
>   Documentation/networking/switchdev.txt           |   59 +
>   MAINTAINERS                                      |   14 +
>   drivers/net/ethernet/Kconfig                     |    1 +
>   drivers/net/ethernet/Makefile                    |    1 +
>   drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
>   drivers/net/ethernet/intel/i40e/i40e_main.c      |    2 +-
>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |    2 +-
>   drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    2 +-
>   drivers/net/ethernet/rocker/Kconfig              |   27 +
>   drivers/net/ethernet/rocker/Makefile             |    5 +
>   drivers/net/ethernet/rocker/rocker.c             | 4182 ++++++++++++++++++++++
>   drivers/net/ethernet/rocker/rocker.h             |  427 +++
>   include/linux/if_bridge.h                        |   18 +
>   include/linux/netdevice.h                        |   48 +-
>   include/net/switchdev.h                          |   53 +
>   include/uapi/linux/if_link.h                     |    1 +
>   net/Kconfig                                      |    1 +
>   net/Makefile                                     |    3 +
>   net/bridge/br_fdb.c                              |   94 +-
>   net/bridge/br_netlink.c                          |    2 +
>   net/bridge/br_stp.c                              |    4 +
>   net/bridge/br_stp_if.c                           |    3 +
>   net/bridge/br_stp_timer.c                        |    2 +
>   net/core/dev.c                                   |    2 +-
>   net/core/net-sysfs.c                             |   26 +-
>   net/core/rtnetlink.c                             |   30 +-
>   net/switchdev/Kconfig                            |   13 +
>   net/switchdev/Makefile                           |    5 +
>   net/switchdev/switchdev.c                        |   93 +
>   29 files changed, 5104 insertions(+), 18 deletions(-)
>   create mode 100644 Documentation/networking/switchdev.txt
>   create mode 100644 drivers/net/ethernet/rocker/Kconfig
>   create mode 100644 drivers/net/ethernet/rocker/Makefile
>   create mode 100644 drivers/net/ethernet/rocker/rocker.c
>   create mode 100644 drivers/net/ethernet/rocker/rocker.h
>   create mode 100644 include/net/switchdev.h
>   create mode 100644 net/switchdev/Kconfig
>   create mode 100644 net/switchdev/Makefile
>   create mode 100644 net/switchdev/switchdev.c
>
