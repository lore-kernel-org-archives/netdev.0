From: Ben Greear <greearb@candelatech.com>
Subject: Re: OOM when adding ipv6 route:  How to make available more per-cpu
 memory?
Date: Fri, 05 Nov 2010 17:07:11 -0700
Message-ID: <4CD49C2F.3060904@candelatech.com>
References: <4CD43C87.5040403@candelatech.com>	 <1288980361.2882.1070.camel@edumazet-laptop>	 <4CD449A5.5070305@candelatech.com>	 <1288988403.2665.268.camel@edumazet-laptop> <1288995103.2665.653.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1288995103.2665.653.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/05/2010 03:11 PM, Eric Dumazet wrote:
> Le vendredi 05 novembre 2010 =C3=A0 21:20 +0100, Eric Dumazet a =C3=A9=
crit :
>> Your vmalloc space is very fragmented. pcpu_get_vm_areas() want
>> hugepages (4MB on your machine, 2MB on mine because I have
>> CONFIG_HIGHMEM64G=3Dy)
>
> Well, this is wrong. We use normal (4KB) pages, unfortunately.
>
> I have a NUMA machine, with two nodes, so pcpu_get_vm_areas() allocat=
es
> two zones, one for each node, with a 'known' offset between them.
> Then, 4KB pages are allocated to populate the zone when needed.
>
> # grep pcpu_get_vm_areas /proc/vmallocinfo
> 0xffffe8ffa0400000-0xffffe8ffa0600000 2097152 pcpu_get_vm_areas+0x0/0=
x740 vmalloc
> 0xffffe8ffffc00000-0xffffe8ffffe00000 2097152 pcpu_get_vm_areas+0x0/0=
x740 vmalloc
>
> BTW, we dont have the number of pages currently allocated in each
> 'vmalloc' zone, and/or node information.
>
> Tejun, do you have plans to use hugepages eventually ?
> (and fallback to 4KB pages, but most percpu data are allocated right
> after boot)

We just tried creating 1000 macvlans with IPv6 addrs on a 64-bit machin=
e
with 12GB RAM.  Only around 520 interfaces properly set their IPs, and
again there are errors about of-of-memory from 'ip', but no obvious
splats in dmesg.

'top' shows 10G or so free.

It will take some time to figure out what exactly is returning
the ENOMEM....

Thanks,
Ben

>
> Thanks
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
