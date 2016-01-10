From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: don't make assumptions on struct
 flow_keys layout
Date: Sun, 10 Jan 2016 17:25:58 -0500 (EST)
Message-ID: <20160110.172558.367101858392871618.davem@davemloft.net>
References: <1452159189-11473-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, haiyangz@microsoft.com,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: vkuznets@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1452159189-11473-1-git-send-email-vkuznets@redhat.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Vitaly Kuznetsov <vkuznets@redhat.com>
Date: Thu,  7 Jan 2016 10:33:09 +0100

> Recent changes to 'struct flow_keys' (e.g commit d34af823ff40 ("net: Add
>  VLAN ID to flow_keys")) introduced a performance regression in netvsc
> driver. Is problem is, however, not the above mentioned commit but the
> fact that netvsc_set_hash() function did some assumptions on the struct
> flow_keys data layout and this is wrong. We need to extract the data we
> need (src/dst addresses and ports) after the dissect.
> 
> The issue could also be solved in a completely different way: as suggested
> by Eric instead of our own homegrown netvsc_set_hash() we could use
> skb_get_hash() which does more or less the same. Unfortunately, the
> testing done by Simon showed that Hyper-V hosts are not happy with our
> Jenkins hash, selecting the output queue with the current algorithm based
> on Toeplitz hash works significantly better.
> 
> Tested-by: Simon Xiao <sixiao@microsoft.com>
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>

Stop using this Toeplitz thing and just use the proper hash the stack
is already calculating for you.

There is no way this is faster, and the continued attempts to
shoe-horn Toeplitz usage into this driver is resulting in incredibly
ugly and rediculous code.

I'm not applying any patches that further the use of Toeplitz as the
hash function in this driver.  You must use the clean,
efficient, facilities the kernel has already for packet hashing.

If every driver did what you guys are doing, we'd be in a heap of
trouble, and I'm simply not going to allow this to continue any
longer.

Thanks.
