From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH] hyperv: Add netpoll support
Date: Tue, 08 Jul 2014 22:16:52 +0200
Message-ID: <53BC51B4.4010703@nod.at>
References: <1404811947-5174-1-git-send-email-richard@nod.at>
 <9fb91c2ee32a4a59a2bec54043a6b9fd@BY2PR03MB299.namprd03.prod.outlook.com>
 <53BC3AC5.6000203@nod.at>
 <b2835410139848be8811403e3d7fa708@BY2PR03MB299.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: KY Srinivasan <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <b2835410139848be8811403e3d7fa708@BY2PR03MB299.namprd03.prod.outlook.com>
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

Am 08.07.2014 22:03, schrieb KY Srinivasan:
> The VCPU the channel is bound to is available in the channel state. You could use the following code
> Fragment to ensure that the call is made on the "right" cpu:
> 
> smp_call_function_single(dev->channel->target_cpu,
>                                          netvsc_channel_cb, dev->channel, true);

This won't work as netpoll runs with IRQs disabled.
->ndo_poll_controller() has to make sure that SKBs can be received and transmitted
while IRQs are off. I thought calling the channel callback by hand would be enough
to receive SKBs.

Thanks,
//richard
