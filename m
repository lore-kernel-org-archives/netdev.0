From: Jason Wang <jasowang@redhat.com>
Subject: Re: linux-next Problems with VPN tunnel - no packets sent
Date: Wed, 03 Dec 2014 03:20:19 +0008
Message-ID: <1417576339.19959.0@smtp.corp.redhat.com>
References: <17929.1417552899@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <17929.1417552899@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, Dec 3, 2014 at 4:41 AM, Valdis Kletnieks 
<Valdis.Kletnieks@vt.edu> wrote:
> Recent linux-next has broken my Juniper VPN client.  The tunnel gets 
> created,
> routes get added, but trying to actually send packets across results 
> in packets
> just disappearing. 'ifconfig' consistently reports exactly 1 packet 
> sent (even
> after a 'ping' command or similar should have sent multiple packets.
> 
> tun0: flags=4305<UP,POINTOPOINT,RUNNING,NOARP,MULTICAST>  mtu 1400
>         inet 172.27.1.40  netmask 255.255.255.255  destination 
> 172.27.1.40
>         unspec 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  
> txqueuelen 500  (UNSPEC)
>         RX packets 1  bytes 355 (355.0 B)
>         RX errors 0  dropped 0  overruns 0  frame 0
>         TX packets 1  bytes 61 (61.0 B)
>         TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
> 
> Still broken in next-20141201, and bisection fingers this commit:
> 
> commit e0b46d0ee9c240c7430a47e9b0365674d4a04522
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Fri Nov 7 21:22:23 2014 +0800
> 
>     tun: Use iovec iterators
> 
>     This patch removes the use of skb_copy_datagram_const_iovec in
>     favour of the iovec iterator-based skb_copy_datagram_iter.
> 
> This commit is in the kernel, and does *not* fix the problem:
> 
> commit 8c847d254146d32c86574a1b16923ff91bb784dd
> Author: Jason Wang <jasowang@redhat.com>
> Date:   Thu Nov 13 16:54:14 2014 +0800
> 
>     tun: fix issues of iovec iterators using in tun_put_user()
> 
> So there's apparently additional issues that Jason didn't address. I 
> tried to
> revert Herbert's patch for testing, but there's at  least 5 or 6 
> other patches
> that need reverting first, so I abandoned that unless it becomes 
> necessary...
> 
> What's the best way to proceed?

See another fixes from Herbert, it probably fixes your issue:

http://marc.info/?l=linux-netdev&m=141734182302021&w=2
