From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 5/6] Drivers: net: hyperv: Enable send side checksum
 offload
Date: Thu, 6 Mar 2014 21:00:39 +0000
Message-ID: <5102a3e2fdc14815a4c4df0ea3c3f763@BY2PR03MB299.namprd03.prod.outlook.com>
References: <1394104390-23477-5-git-send-email-kys@microsoft.com>
	<20140306.143354.1296864763659469552.davem@davemloft.net>
	<d51892af73814794972736463a686a09@BY2PR03MB299.namprd03.prod.outlook.com>
 <20140306.154842.1612603056023919814.davem@davemloft.net>
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
In-Reply-To: <20140306.154842.1612603056023919814.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, March 7, 2014 2:19 AM
> To: KY Srinivasan
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> jasowang@redhat.com
> Subject: Re: [PATCH 5/6] Drivers: net: hyperv: Enable send side checksum
> offload
> 
> From: KY Srinivasan <kys@microsoft.com>
> Date: Thu, 6 Mar 2014 20:29:13 +0000
> 
> >
> >
> >> -----Original Message-----
> >> From: David Miller [mailto:davem@davemloft.net]
> >> Sent: Friday, March 7, 2014 1:04 AM
> >> To: KY Srinivasan
> >> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> >> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> >> jasowang@redhat.com
> >> Subject: Re: [PATCH 5/6] Drivers: net: hyperv: Enable send side
> >> checksum offload
> >>
> >> From: "K. Y. Srinivasan" <kys@microsoft.com>
> >> Date: Thu,  6 Mar 2014 03:13:09 -0800
> >>
> >> > +bool get_net_transport_info(struct sk_buff *skb, bool *is_v4,
> >> > +				bool *is_tcp, bool *is_udp, u32 *trans_off) {
> >>
> >> Returning so many values like this is awkward, at best.
> >>
> >> Why not return a well defined bitmask:
> >>
> >> #define TRANSPORT_INFO_SUCCESS	0x00000001
> >> #define TRANSPORT_INFO_TCP	0x00000002
> >> #define TRANSPORT_INFO_UDP	0x00000004
> >>
> >> Then the only value you have to return by reference is trans_off.
> >
> > I also need information on the IP version as well. If it is ok with
> > you, I will use the return value to get information on the network
> > protocol and return information on transport via reference - protocol and
> the offset.
> 
> Just add "TRANSPORT_INFO_IPv4" as another bitmask in the return value.

The network information is independent of the transport information - I can partition the
return value to encode all the possible network and transport combination and subsequently
parse the network and transport information. I will go ahead and code it up this way.

Regards,

K. Y

 
