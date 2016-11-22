From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: net/icmp: null-ptr-deref in icmp6_send
Date: Tue, 22 Nov 2016 14:14:33 -0500
Message-ID: <59A60049-B985-43E8-84C7-B413A544AFF4@cumulusnetworks.com>
References: <CAAeHK+wRE7y_0d7djWnq9S1O_w-1wQRq1g7VsAmzEAE+JY_v2Q@mail.gmail.com> <CAM_iQpUQtt2CGrYF4H2DJv_NRsmnBqkXj5rJVXD8osJBFz_qYw@mail.gmail.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
        charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpUQtt2CGrYF4H2DJv_NRsmnBqkXj5rJVXD8osJBFz_qYw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Sent from my iPhone

> On Nov 22, 2016, at 1:11 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>=20
>> On Tue, Nov 22, 2016 at 2:23 AM, Andrey Konovalov <andreyknvl@google.com>=
 wrote:
>> Hi,
>>=20
>> I've got the following error report while fuzzing the kernel with syzkall=
er.
>>=20
>> It seems that skb_dst(skb) may end up being NULL.
>>=20
>> As far as I can see the bug was introduced in commit 5d41ce29e ("net:
>> icmp6_send should use dst dev to determine L3 domain").
>> ICMP v4 probaly has similar issue due to 9d1a6c4ea ("net:
>> icmp_route_lookup should use rt dev to determine L3 domain").
>=20
>=20
> ipv6_parse_hopopts() is called before NF_INET_PRE_ROUTING,
> so the skb_dst could be NULL.
>=20
> I have no idea what commit 5d41ce29e tried to fix, but we already
> use skb->dev a few lines before l3mdev_master_ifindex(), so I don't
> understand why skb->dev could be NULL, maybe just for vrf dev?

On PTO this week and currently at the beach. Will take a look tonight. Thank=
s for the report.=20=
