From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 0/3] support changing steering policies in tuntap
Date: Thu, 28 Sep 2017 15:23:34 +0800
Message-ID: <26f01b12-396e-6319-0eed-c987930e0ed9@redhat.com>
References: <1506500637-13881-1-git-send-email-jasowang@redhat.com>
 <20170927230042-mutt-send-email-mst@kernel.org>
 <CAF=yD-J8hERZdwq8FJ2rtnCnZ2b7s=CAVLtPk4CS7e=RQH3sLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAF=yD-J8hERZdwq8FJ2rtnCnZ2b7s=CAVLtPk4CS7e=RQH3sLQ@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年09月28日 07:25, Willem de Bruijn wrote:
>>> In the future, both simple and sophisticated policy like RSS or other guest
>>> driven steering policies could be done on top.
>> IMHO there should be a more practical example before adding all this
>> indirection. And it would be nice to understand why this queue selection
>> needs to be tun specific.
> I was thinking the same and this reminds me of the various strategies
> implemented in packet fanout. tun_cpu_select_queue is analogous to
> fanout_demux_cpu though it is tun-specific in that it requires tun->numqueues.

Right, the main idea is to introduce a way to change flow steering 
policy for tun. I think fanout policy could be implemented through the 
API introduced in this series. (Current flow caches based automatic 
steering method is tun specific).

>
> Fanout accrued various strategies until it gained an eBPF variant. Just
> supporting BPF is probably sufficient here, too.

Technically yes, but for tun, it also serve for virt. We probably still 
need some hard coded policy which could be changed by guest until we can 
accept an BPF program from guest I think?

Thanks
