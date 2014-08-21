From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH V2 0/1] ipv4: net namespace does not inherit network
 configurations
Date: Wed, 20 Aug 2014 20:18:43 -0700
Message-ID: <20140820201843.083a45d9@uryu.home.lan>
References: <1408588321-13537-1-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Yue.Tao@windriver.com, alexandre.dietsch@windriver.com,
	davem@davemloft.net, honkiko@gmail.com, cwang@twopensource.com,
	Zhu Yanjun <Yanjun.Zhu@windriver.com>
To: Zhu Yanjun <zyjzyj2000@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408588321-13537-1-git-send-email-Yanjun.Zhu@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 21 Aug 2014 10:32:00 +0800
Zhu Yanjun <zyjzyj2000@gmail.com> wrote:

> V2: Following the advice from Cong Wang, I submit a patch as normal.
> 
> Hi,all
> 
> I did a test on kernel3.16 rc6:
> 
> root@qemu1:~# echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
> root@qemu1:~# echo 1 > /proc/sys/net/ipv4/conf/all/forwarding
> root@qemu1:~# ip netns list
> root@qemu1:~# ip netns add fib1
> root@qemu1:~# ip netns exec fib1 bash
> root@qemu1:~# cat /proc/sys/net/ipv6/conf/all/forwarding
> 0
> root@qemu1:~# cat /proc/sys/net/ipv4/conf/all/forwarding
> 1
> 
> The behavior of ipv4 and ipv6 is very inconsistent. I checked
> the kernel source code. I found that from this patch
> [ipv6: fix bad free of addrconf_init_net], the above difference
> appeared.
> 
> Since a net namespace is independent to another. That is, there
> is no any relationship between the net namespaces. So the behavior
> of ipv4 is not correct.
> 
> Based on this patch [ipv6: fix bad free of addrconf_init_net], I made
> a new patch to fix this problem on ipv4.
> 
> Any reply is appreciated. 
> 
> Zhu Yanjun (1):
>   ipv4: net namespace does not inherit network configurations
> 
>  net/ipv4/devinet.c | 29 ++++++++++++-----------------
>  1 file changed, 12 insertions(+), 17 deletions(-)
> 

This a semantic change to network namespaces and therefore is
likely to break existing applications using network namespaces.
