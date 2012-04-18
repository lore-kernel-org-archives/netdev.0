From: Jonathan Nieder <jrnieder@gmail.com>
Subject: Re: [PATCH] set fake_rtable's dst to NULL to avoid kernel Oops.
Date: Wed, 18 Apr 2012 14:04:50 -0500
Message-ID: <20120418190450.GA30185@burratino>
References: <000001cd1c62$75d10de0$617329a0$%huangpeng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, "'David S. Miller'" <davem@davemloft.net>,
	netdev@vger.kernel.org, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, ctrix+debianbugs@navynet.it,
	peter.huangpeng@gmail.com, harry.majun@huawei.com
To: "Peter Huang (Peng)" <peter.huangpeng@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <000001cd1c62$75d10de0$617329a0$%huangpeng@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Peter Huang (Peng) wrote:

> When bridge is deleted before tap/vif device's delete, kernel may
> encounter an oops because of NULL reference to fake_rtable's dst.
>
> Set fake_rtable's dst to NULL before sending packets out can solve
> this problem.
>
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Peter Huang <peter.huangpeng@huawei.com>
> ---
> include/linux/netfilter_bridge.h |    8 ++++++++
>  net/bridge/br_forward.c          |    1 +
>  net/bridge/br_netfilter.c        |    6 +-----
>  3 files changed, 10 insertions(+), 5 deletions(-)

Massimo Cetra (cc-ed) tested the patch against a 3.2.y kernel and wrote[1]:

> The patch i applied yesterday to the debian kernel has been installed 
> and the kernel is not panic-ing anymore.
>
> I'll try to keep this bug up to date.

So it seems to work.  Dave, please consider queuing this for stable@
when the final patch is ready.

Thanks,
Jonathan

[1] http://bugs.debian.org/668511#37
