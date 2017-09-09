From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] ipv4: Namespaceify tcp_max_orphans knob
Date: Fri, 8 Sep 2017 21:35:02 -0700
Message-ID: <CAM_iQpVDM0HwZd6c+Loych=nQE__eGteeJQ=XTOfHKgVxMRfrA@mail.gmail.com>
References: <1504753808-13266-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <CAM_iQpV4gRwhT4VXPtJft38ixG6xE3PF9z4gB7HHJEUsqbCtOw@mail.gmail.com> <798CA25A-CA09-4D06-A9B6-7C5791A6EEC1@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Eric Dumazet <edumazet@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: =?UTF-8?B?5Lil5rW35Y+M?= <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <798CA25A-CA09-4D06-A9B6-7C5791A6EEC1@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 8, 2017 at 6:25 PM, =E4=B8=A5=E6=B5=B7=E5=8F=8C <yanhaishuang@c=
mss.chinamobile.com> wrote:
>
>
>> On 2017=E5=B9=B49=E6=9C=889=E6=97=A5, at =E4=B8=8A=E5=8D=886:13, Cong Wa=
ng <xiyou.wangcong@gmail.com> wrote:
>>
>> On Wed, Sep 6, 2017 at 8:10 PM, Haishuang Yan
>> <yanhaishuang@cmss.chinamobile.com> wrote:
>>> Different namespace application might require different maximal number
>>> of TCP sockets independently of the host.
>>
>> So after your patch we could have N * net->ipv4.sysctl_tcp_max_orphans
>> in a whole system, right? This just makes OOM easier to trigger.
>>
>
> From my understanding, before the patch, we had N * net->ipv4.sysctl_tcp_=
max_orphans,
> and after the patch, we could have ns1.sysctl_tcp_max_orphans + ns2.sysct=
l_tcp_max_orphans
> + ns3.sysctl_tcp_max_orphans, is that right? Thanks for your reviewing.

Nope, by N I mean the number of containers. Before your patch, the limit
is global, after your patch it is per container.
