From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH RFC net-next] netvsc: get rid of completion timeouts
Date: Wed, 08 Jun 2016 18:05:57 +0200
Message-ID: <87inxjacnu.fsf@vitty.brq.redhat.com>
References: <1465395546-28272-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, Haiyang Zhang <haiyangz@microsoft.com>,
 linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1465395546-28272-1-git-send-email-vkuznets@redhat.com> (Vitaly
 Kuznetsov's message of "Wed, 8 Jun 2016 16:19:06 +0200")
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

Vitaly Kuznetsov <vkuznets@redhat.com> writes:

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
> appear. netvsc_sc_open() does unconditional nvscdev->num_sc_offered-- and
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

Kbuild test robot reports an unused variable after the patch, I'll fix
this and resend together with a related fix so please don't apply this
RFC to net-next atm.

[skip]

-- 
  Vitaly
