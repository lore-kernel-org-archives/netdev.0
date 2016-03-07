From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: Move subchannel waiting to
 rndis_filter_device_remove()
Date: Mon, 07 Mar 2016 15:38:09 -0500 (EST)
Message-ID: <20160307.153809.1538719544106524749.davem@davemloft.net>
References: <1457132863-7262-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1457132863-7262-1-git-send-email-haiyangz@microsoft.com>
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

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Fri,  4 Mar 2016 15:07:43 -0800

> During hot add, vmbus_device_register() is called from vmbus_onoffer(), on
> the same workqueue as the subchannel offer message work-queue, so 
> subchannel offer won't be processed until the vmbus_device_register()/...
> /netvsc_probe() is done.
> Also, vmbus_device_register() is called with channel_mutex locked, which
> prevents subchannel processing too. So the "waiting for sub-channel 
> processing" will not success in hot add case. But, in usual module loading,
> the netvsc_probe() is called from different code path, and doesn't fail.
> 
> This patch resolves the deadlock during NIC hot-add, and speeds up NIC 
> loading time.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Applied, thanks.
