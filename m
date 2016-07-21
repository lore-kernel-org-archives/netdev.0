From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH] net: bridge: br_set_ageing_time takes a clock_t
Date: Thu, 21 Jul 2016 14:18:59 -0400
Message-ID: <874m7ilur0.fsf@ketchup.mtl.sfl>
References: <20160721164219.26723-1-vivien.didelot@savoirfairelinux.com> <CAM_iQpUzf6MiOqYNc-vX0A-mhZ_=URwVPoUD1TY7xC0amTZoww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpUzf6MiOqYNc-vX0A-mhZ_=URwVPoUD1TY7xC0amTZoww@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Cong,

Cong Wang <xiyou.wangcong@gmail.com> writes:

> On Thu, Jul 21, 2016 at 9:42 AM, Vivien Didelot
> <vivien.didelot@savoirfairelinux.com> wrote:
>> Change the ageing_time type in br_set_ageing_time() from u32 to what it
>> is expected to be, i.e. a clock_t.
>
> You also need to change struct switchdev_attr:
>
> struct switchdev_attr {
>         struct net_device *orig_dev;
>         enum switchdev_attr_id id;
>         u32 flags;
>         void *complete_priv;
>         void (*complete)(struct net_device *dev, int err, void *priv);
>         union {
>                 struct netdev_phys_item_id ppid;        /* PORT_PARENT_ID */
>                 u8 stp_state;                           /* PORT_STP_STATE */
>                 unsigned long brport_flags;             /* PORT_BRIDGE_FLAGS */
>                 u32 ageing_time;                        /* BRIDGE_AGEING_TIME */
>                 bool vlan_filtering;                    /*
> BRIDGE_VLAN_FILTERING */
>         } u;
> };

Already changed in net/master as of eabfdda93477
("net: switchdev: change ageing_time type to clock_t").

Thanks,

        Vivien
