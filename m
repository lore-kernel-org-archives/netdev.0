From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [BUG] net/ipv4: inconsistent routing table
Date: Wed, 05 Aug 2015 11:06:15 +0200
Message-ID: <55C1D207.3040905@iogearbox.net>
References: <CAOrge3qi=7YPRO+VeCDvHsm_7SFC4Y=+JpwQtwAV3zk_q4fEAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Zang MingJie <zealot0630@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOrge3qi=7YPRO+VeCDvHsm_7SFC4Y=+JpwQtwAV3zk_q4fEAw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ please cc netdev ]

On 08/05/2015 10:56 AM, Zang MingJie wrote:
> Hi:
>
> I found a bug when remove an ip address which is referenced by a routing entry.
>
> step to reproduce:
>
> ip li add type dummy
> ip li set dummy0 up
> ip ad add 10.0.0.1/24 dev dummy0
> ip ad add 10.0.0.2/24 dev dummy0
> ip ro add default via 10.0.0.2/24
> ip ad del 10.0.0.2/24 dev dummy0
>
> after deleting the secondary ip address, the routing entry still
> pointing to 10.0.0.2
>
> # ip ro
> default via 10.0.0.2 dev dummy0
> 10.0.0.0/24 dev dummy0  proto kernel  scope link  src 10.0.0.1
>
> but actually, kernel considers the default route is directly connected.
>
> # ip ro get 1.1.1.1
> 1.1.1.1 dev dummy0  src 10.0.0.1
>      cache
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
