From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2,1/1] net/hyperv: Fix the code handling tx busy
Date: Mon, 19 Mar 2012 17:27:17 -0400 (EDT)
Message-ID: <20120319.172717.567266094785758733.davem@davemloft.net>
References: <1332192233-32305-1-git-send-email-haiyangz@microsoft.com>
	<1332192233-32305-2-git-send-email-haiyangz@microsoft.com>
	<1332192191.9397.62.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, haiyangz@microsoft.com,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: eric.dumazet@gmail.com
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <1332192191.9397.62.camel@edumazet-glaptop>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 19 Mar 2012 14:23:11 -0700

> On Mon, 2012-03-19 at 14:23 -0700, Haiyang Zhang wrote:
>> Instead of dropping the packet, we keep the skb buffer, and return
>> NETDEV_TX_BUSY to let upper layer retry send. This will not cause
>> endless loop, because the host is taking data away from ring buffer,
>> and we have called the stop_queue before returning NETDEV_TX_BUSY.
>> 
>> The stop_queue was called in the function netvsc_send() in file 
>> netvsc.c, then it returns to rndis_filter_send(), which returns to
>> netvsc_start_xmit() in file netvsc_drv.c. So the NETDEV_TX_BUSY is
>> indeed returned AFTER queue is stopped.
>> 
>> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
>> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
>> ---
> 
> Thanks 
> 
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
