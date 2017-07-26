From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net: inet: diag: expose sockets cgroup classid
Date: Wed, 26 Jul 2017 15:01:32 -0700
Message-ID: <CAM_iQpWJur_+hFZwj8bLa3bZwEd=aT5mWdhfapd5E9h9Q0HVUg@mail.gmail.com>
References: <20170726172153.23436-1-alexander.levin@verizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
        "yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170726172153.23436-1-alexander.levin@verizon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 26, 2017 at 10:22 AM, Levin, Alexander (Sasha Levin)
<alexander.levin@verizon.com> wrote:
> +       if (ext & (1 << (INET_DIAG_CLASS_ID - 1))) {
> +               u32 classid = 0;
> +
> +#ifdef CONFIG_SOCK_CGROUP_DATA
> +               classid = sock_cgroup_classid(&sk->sk_cgrp_data);
> +#endif


If CONFIG_SOCK_CGROUP_DATA is not enabled, should we put 0
or put nothing (that is, skipping this nla_put())?

> +
> +               nla_put(skb, INET_DIAG_CLASS_ID, sizeof(classid), &classid);

nla_put_u32()

Thanks.
