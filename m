From: =?gb2312?B?0c+6o8ur?= <yanhaishuang@cmss.chinamobile.com>
Subject: Re: [PATCH] ipv4: Namespaceify tcp_max_orphans knob
Date: Sat, 9 Sep 2017 13:09:57 +0800
Message-ID: <E15E5C56-D712-4FEF-9AC5-AE28857D8D27@cmss.chinamobile.com>
References: <1504753808-13266-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <CAM_iQpV4gRwhT4VXPtJft38ixG6xE3PF9z4gB7HHJEUsqbCtOw@mail.gmail.com>
 <798CA25A-CA09-4D06-A9B6-7C5791A6EEC1@cmss.chinamobile.com>
 <CAM_iQpVDM0HwZd6c+Loych=nQE__eGteeJQ=XTOfHKgVxMRfrA@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Eric Dumazet <edumazet@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpVDM0HwZd6c+Loych=nQE__eGteeJQ=XTOfHKgVxMRfrA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> On 2017年9月9日, at 下午12:35, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> 
> On Fri, Sep 8, 2017 at 6:25 PM, 严海双 <yanhaishuang@cmss.chinamobile.com> wrote:
>> 
>> 
>>> On 2017年9月9日, at 上午6:13, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> 
>>> On Wed, Sep 6, 2017 at 8:10 PM, Haishuang Yan
>>> <yanhaishuang@cmss.chinamobile.com> wrote:
>>>> Different namespace application might require different maximal number
>>>> of TCP sockets independently of the host.
>>> 
>>> So after your patch we could have N * net->ipv4.sysctl_tcp_max_orphans
>>> in a whole system, right? This just makes OOM easier to trigger.
>>> 
>> 
>> From my understanding, before the patch, we had N * net->ipv4.sysctl_tcp_max_orphans,
>> and after the patch, we could have ns1.sysctl_tcp_max_orphans + ns2.sysctl_tcp_max_orphans
>> + ns3.sysctl_tcp_max_orphans, is that right? Thanks for your reviewing.
> 
> Nope, by N I mean the number of containers. Before your patch, the limit
> is global, after your patch it is per container.
> 

Yeah, for example, if there is N containers, before the patch, I mean the limit is:

	N * net->ipv4.sysctl_tcp_max_orphans

After the patch, the limit is:

	ns1. net->ipv4.sysctl_tcp_max_orphans + ns2. net->ipv4.sysctl_tcp_max_orphans + …
