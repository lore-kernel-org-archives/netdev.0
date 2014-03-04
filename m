From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hyperv: Move state setting for link query
Date: Tue, 4 Mar 2014 19:36:04 +0000
Message-ID: <2f61f102bf3d4185b31c5020caab5464@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1393890875-1420-1-git-send-email-haiyangz@microsoft.com>
 <531543FD.7090907@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jason Wang <jasowang@redhat.com>, "davem@davemloft.net"
 <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <531543FD.7090907@redhat.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Jason Wang [mailto:jasowang@redhat.com]
> Sent: Monday, March 3, 2014 10:10 PM
> To: Haiyang Zhang; davem@davemloft.net; netdev@vger.kernel.org
> Cc: KY Srinivasan; olaf@aepfle.de; linux-kernel@vger.kernel.org; driverdev-
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net-next] hyperv: Move state setting for link query
> 
> On 03/04/2014 07:54 AM, Haiyang Zhang wrote:
> > It moves the state setting for query into rndis_filter_receive_response().
> > All callbacks including query-complete and status-callback are
> > synchronized by channel->inbound_lock. This prevents pentential race
> between them.
> 
> This still looks racy to me. The problem is workqueue is not synchronized with
> those here.
> 
> Consider the following case in netvsc_link_change():
> 
>     if (rdev->link_state) {
>     ... receive interrupt ...
>     rndis_filter_receice_response() which changes rdev->link_state
>     ...
>         netif_carrier_off()
>     }
> 
> And also it need to schedule a work otherwise the link status is out of sync.

I will update this patch to schedule a work by the end of probe function.

Thanks,
- Haiyang
