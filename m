From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH net-next 1/1] hv_netvsc: Wait for sub-channels to be
 processed during probe
Date: Fri, 17 Jul 2015 10:07:03 +0000
Message-ID: <ed6433db194c4f2393cc462b538d9b2f@SIXPR30MB031.064d.mgd.msft.net>
References: <1437074222-13020-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KY Srinivasan <kys@microsoft.com>, "davem@davemloft.net"
 <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>,
 "jasowang@redhat.com" <jasowang@redhat.com>, "vkuznets@redhat.com"
 <vkuznets@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1437074222-13020-1-git-send-email-kys@microsoft.com>
Content-Language: en-US
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

> From: K. Y. Srinivasan
> Sent: Friday, July 17, 2015 3:17
> Subject: [PATCH net-next 1/1] hv_netvsc: Wait for sub-channels to be processed
> during probe
> 
> The current code returns from probe without waiting for the proper handling
> of subchannels that may be requested. If the netvsc driver were to be rapidly
> loaded/unloaded, we can  trigger a panic as the unload will be tearing
> down state that may not have been fully setup yet. We fix this issue by making
> sure that we return from the probe call only after ensuring that the
> sub-channel offers in flight are properly handled.
> 
> ---
>  drivers/net/hyperv/hyperv_net.h   |    2 ++
>  drivers/net/hyperv/rndis_filter.c |   25 +++++++++++++++++++++++++
>  2 files changed, 27 insertions(+), 0 deletions(-)

BTW, not sure if we should make the same fix to storvsc.

IMO storvsc should have the same issue, at least in theory, though usually it's
unlikely to unload storvsc.  :-)

Thanks,
-- Dexuan
