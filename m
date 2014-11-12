From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hyperv: Add processing of MTU reduced by the
 host
Date: Wed, 12 Nov 2014 20:02:11 +0000
Message-ID: <ecc2fd8e646147fabb30d3120c889431@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1415748472-27463-1-git-send-email-haiyangz@microsoft.com>
 <20141112.144640.703336197189868183.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141112.144640.703336197189868183.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, November 12, 2014 2:47 PM
> To: Haiyang Zhang
> Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
> jasowang@redhat.com; linux-kernel@vger.kernel.org; driverdev-
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net-next] hyperv: Add processing of MTU reduced by
> the host
> 
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Tue, 11 Nov 2014 15:27:52 -0800
> 
> > -	if (mtu < 68 || mtu > limit)
> > +	if (mtu < ETH_DATA_LEN || mtu > limit)
> >  		return -EINVAL;
> 
> This is not correct.
> 
> The test is against the minimally supported MTU, which should
> be 68 not ETH_DATA_LEN which is 1500.

The Hyper-V host doesn't support MTU below 1500. If we try setting MTU to a 
value < 1500, the host will use 1500 automatically and return 1500 in the 
RNDIS_OID_GEN_MAXIMUM_FRAME_SIZE query and guest will also use it. That's 
why I set the lower limit to ETH_DATA_LEN.

Are you suggesting that we keep the 68 as the lower limit, and let the host 
auto-reset it to 1500 when we trying to set an MTU < 1500?

Thanks,
- Haiyang
