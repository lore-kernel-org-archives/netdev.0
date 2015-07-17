From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net-next 1/1] hv_netvsc: Wait for sub-channels to be
 processed during probe
Date: Fri, 17 Jul 2015 15:34:21 +0000
Message-ID: <BY2PR0301MB16548DDDA965459CCD308983A0980@BY2PR0301MB1654.namprd03.prod.outlook.com>
References: <1437074222-13020-1-git-send-email-kys@microsoft.com>
 <ed6433db194c4f2393cc462b538d9b2f@SIXPR30MB031.064d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Dexuan Cui <decui@microsoft.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"vkuznets@redhat.com" <vkuznets@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ed6433db194c4f2393cc462b538d9b2f@SIXPR30MB031.064d.mgd.msft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Dexuan Cui
> Sent: Friday, July 17, 2015 3:07 AM
> To: KY Srinivasan; davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com; vkuznets@redhat.com
> Cc: KY Srinivasan
> Subject: RE: [PATCH net-next 1/1] hv_netvsc: Wait for sub-channels to be
> processed during probe
> 
> > From: K. Y. Srinivasan
> > Sent: Friday, July 17, 2015 3:17
> > Subject: [PATCH net-next 1/1] hv_netvsc: Wait for sub-channels to be
> processed
> > during probe
> >
> > The current code returns from probe without waiting for the proper
> handling
> > of subchannels that may be requested. If the netvsc driver were to be
> rapidly
> > loaded/unloaded, we can  trigger a panic as the unload will be tearing
> > down state that may not have been fully setup yet. We fix this issue by
> making
> > sure that we return from the probe call only after ensuring that the
> > sub-channel offers in flight are properly handled.
> >
> > ---
> >  drivers/net/hyperv/hyperv_net.h   |    2 ++
> >  drivers/net/hyperv/rndis_filter.c |   25 +++++++++++++++++++++++++
> >  2 files changed, 27 insertions(+), 0 deletions(-)
> 
> BTW, not sure if we should make the same fix to storvsc.
> 
> IMO storvsc should have the same issue, at least in theory, though usually it's
> unlikely to unload storvsc.  :-)

You are right; I am planning to submit a similar patch for storvsc. As you note,
this scenario is unlikely for sorvsc.

K. Y
> 
> Thanks,
> -- Dexuan
