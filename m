From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH RFC net-next] netvsc: get rid of completion timeouts
Date: Wed, 8 Jun 2016 14:31:03 +0000
Message-ID: <CY1PR03MB2284D095D1651ED4EE9BCB85CA5E0@CY1PR03MB2284.namprd03.prod.outlook.com>
References: <1465395546-28272-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1465395546-28272-1-git-send-email-vkuznets@redhat.com>
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



> -----Original Message-----
> From: Vitaly Kuznetsov [mailto:vkuznets@redhat.com]
> Sent: Wednesday, June 8, 2016 10:19 AM
> To: netdev@vger.kernel.org
> Cc: devel@linuxdriverproject.org; linux-kernel@vger.kernel.org; KY
> Srinivasan <kys@microsoft.com>; Haiyang Zhang <haiyangz@microsoft.com>
> Subject: [PATCH RFC net-next] netvsc: get rid of completion timeouts
> 
> I'm hitting 5 second timeout in rndis_filter_set_rss_param() while setting
> RSS parameters for the device. When this happens we end up returning
> -ETIMEDOUT from the function and rndis_filter_device_add() falls back to
> setting
> 
> 	net_device->max_chn = 1;
>         net_device->num_chn = 1;
>         net_device->num_sc_offered = 0;
> 
> but after a moment the rndis request succeeds and subchannels start to
> appear. netvsc_sc_open() does unconditional nvscdev->num_sc_offered--
> and
> it becomes U32_MAX-1. Consequent rndis_filter_device_remove() will hang
> while waiting for all U32_MAX-1 subchannels to appear and this is not
> going to happen.
> 
> The immediate issue could be solved by adding num_sc_offered > 0 check to
> netvsc_sc_open() but we're getting out of sync with the host and it's not
> easy to adjust things later, e.g. in this particular case we'll be creating
> queues without a user request for it and races are expected. Same applies
> to other parts of the driver which have the same completion timeout.
> 
> Following the trend in drivers/hv/* code I suggest we remove all these
> timeouts completely. As a guest we can always trust the host we're running
> on and if the host screws things up there is no easy way to recover anyway.
> 
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>

Thank you.
Acked-by: Haiyang Zhang <haiyangz@microsoft.com>
