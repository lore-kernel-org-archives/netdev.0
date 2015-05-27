From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net-next 1/1] hv_netvsc: Properly size the vrss queues
Date: Wed, 27 May 2015 18:20:31 +0000
Message-ID: <BY2PR0301MB071142F4C2A1428235C70E41A0CB0@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <1432682469-15033-1-git-send-email-kys@microsoft.com>
 <20150527.141248.2127547726940414483.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150527.141248.2127547726940414483.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, May 27, 2015 11:13 AM
> To: KY Srinivasan
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> jasowang@redhat.com
> Subject: Re: [PATCH net-next 1/1] hv_netvsc: Properly size the vrss queues
> 
> From: "K. Y. Srinivasan" <kys@microsoft.com>
> Date: Tue, 26 May 2015 16:21:09 -0700
> 
> > The current algorithm for deciding on the number of VRSS channels is
> > not optimal since we open up the min of number of CPUs online and the
> > number of VRSS channels the host is offering. So on a 32 VCPU guest
> > we could potentially open 32 VRSS subchannels. Experimentation has
> > shown that it is best to limit the number of VRSS channels to the number
> > of CPUs within a NUMA node. As part of this work introduce a module
> > parameter to control the number of sub-channels we would open up as
> well.
> > Here is the new algorithm for deciding on the number of sub-channels we
> > would open up:
> >         1) Pick the minimum of what the host is offering and what the driver
> >            in the guest is specifying via the module parameter.
> >         2) Pick the minimum of (1) and the numbers of CPUs in the NUMA
> >            node the primary channel is bound to.
> >
> > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> 
> No new module parameters, sorry.
> 
> You will have to make it such that this can be changed at run time,
> and use a generic run-time mechanism to configure this value that any
> driver can use.
> 
> I will not accept: "this is not possible" or "this is too hard" as a
> reason why you have to use a module parameter.
> 
> Settings that cannot be set at run time are painful for people who run
> large scale operations where resetting entire systems to change a
> setting is completely and utterly impractical.

Agreed; we are working on full ethtool support to address this very issue. The
module parameter that I introduced here was just a temporary solution until 
the  full ethtool support. I will get rid of the module parameter and resubmit this patch.

Regards,

K. Y 
