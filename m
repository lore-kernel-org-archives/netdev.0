From: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Subject: Re: [PATCH] net: inet: diag: expose sockets cgroup classid
Date: Wed, 26 Jul 2017 22:59:19 +0000
Message-ID: <20170726230142.hxvdgkmsui3nbmub@sasha-lappy>
References: <20170726172153.23436-1-alexander.levin@verizon.com>
 <CAM_iQpWJur_+hFZwj8bLa3bZwEd=aT5mWdhfapd5E9h9Q0HVUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
        "yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpWJur_+hFZwj8bLa3bZwEd=aT5mWdhfapd5E9h9Q0HVUg@mail.gmail.com>
Content-Language: en-US
Content-ID: <1974961931FD4342AE38F188F211C10C@vzwcorp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 26, 2017 at 03:01:32PM -0700, Cong Wang wrote:
>On Wed, Jul 26, 2017 at 10:22 AM, Levin, Alexander (Sasha Levin)
><alexander.levin@verizon.com> wrote:
>> +       if (ext & (1 << (INET_DIAG_CLASS_ID - 1))) {
>> +               u32 classid =3D 0;
>> +
>> +#ifdef CONFIG_SOCK_CGROUP_DATA
>> +               classid =3D sock_cgroup_classid(&sk->sk_cgrp_data);
>> +#endif
>
>
>If CONFIG_SOCK_CGROUP_DATA is not enabled, should we put 0
>or put nothing (that is, skipping this nla_put())?

My logic was that if CONFIG_SOCK_CGROUP_DATA is disabled, then all sockets =
have the same default classid =3D=3D> 0, rather than having to deal with wh=
ether that config is enabled or not.

>> +
>> +               nla_put(skb, INET_DIAG_CLASS_ID, sizeof(classid), &class=
id);
>
>nla_put_u32()

Will fix, thanks!

--=20

Thanks,
Sasha=
