From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC PATCH v3] net: sched: convert qdisc linked list to hashtable
Date: Tue, 12 Jul 2016 10:36:28 -0700
Message-ID: <CAM_iQpV0QskOZd9A5LCGPsFC0nunyOmWNcExdt1gi1mgL0dB0w@mail.gmail.com>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm>
 <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160414151813.GE3715@orbyte.nwl.cc> <alpine.LNX.2.00.1604141807350.27368@cbobk.fhfr.pm>
 <1460656170.10638.61.camel@edumazet-glaptop3.roam.corp.google.com>
 <5710E1C1.2090209@mojatatu.com> <1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com>
 <alpine.LNX.2.00.1607071102010.24757@cbobk.fhfr.pm> <alpine.LNX.2.00.1607072234190.24757@cbobk.fhfr.pm>
 <alpine.LNX.2.00.1607111557080.24757@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jiri Kosina <jikos@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1607111557080.24757@cbobk.fhfr.pm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 11, 2016 at 7:02 AM, Jiri Kosina <jikos@kernel.org> wrote:
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index f45929c..0b5c172e 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -52,6 +52,7 @@
>  #include <uapi/linux/netdevice.h>
>  #include <uapi/linux/if_bonding.h>
>  #include <uapi/linux/pkt_cls.h>
> +#include <linux/hashtable.h>
>
>  struct netpoll_info;
>  struct device;
> @@ -1778,6 +1779,7 @@ struct net_device {
>         unsigned int            num_tx_queues;
>         unsigned int            real_num_tx_queues;
>         struct Qdisc            *qdisc;
> +       DECLARE_HASHTABLE       (qdisc_hash, 4);
>         unsigned long           tx_queue_len;
>         spinlock_t              tx_global_lock;
>         int                     watchdog_timeo;

Should it be surrounded by CONFIG_NET_SCHED?
To save several bytes for !CONFIG_NET_SCHED case.
