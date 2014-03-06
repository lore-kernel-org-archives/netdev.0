From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] Drivers: net: hyperv: Enable send side checksum
 offload
Date: Thu, 06 Mar 2014 15:48:42 -0500 (EST)
Message-ID: <20140306.154842.1612603056023919814.davem@davemloft.net>
References: <1394104390-23477-5-git-send-email-kys@microsoft.com>
 <20140306.143354.1296864763659469552.davem@davemloft.net>
 <d51892af73814794972736463a686a09@BY2PR03MB299.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <d51892af73814794972736463a686a09@BY2PR03MB299.namprd03.prod.outlook.com>
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

From: KY Srinivasan <kys@microsoft.com>
Date: Thu, 6 Mar 2014 20:29:13 +0000

> 
> 
>> -----Original Message-----
>> From: David Miller [mailto:davem@davemloft.net]
>> Sent: Friday, March 7, 2014 1:04 AM
>> To: KY Srinivasan
>> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
>> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
>> jasowang@redhat.com
>> Subject: Re: [PATCH 5/6] Drivers: net: hyperv: Enable send side checksum
>> offload
>> 
>> From: "K. Y. Srinivasan" <kys@microsoft.com>
>> Date: Thu,  6 Mar 2014 03:13:09 -0800
>> 
>> > +bool get_net_transport_info(struct sk_buff *skb, bool *is_v4,
>> > +				bool *is_tcp, bool *is_udp, u32 *trans_off) {
>> 
>> Returning so many values like this is awkward, at best.
>> 
>> Why not return a well defined bitmask:
>> 
>> #define TRANSPORT_INFO_SUCCESS	0x00000001
>> #define TRANSPORT_INFO_TCP	0x00000002
>> #define TRANSPORT_INFO_UDP	0x00000004
>> 
>> Then the only value you have to return by reference is trans_off.
> 
> I also need information on the IP version as well. If it is ok with you, I will use the return
> value to get information on the network protocol and return information on transport via
> reference - protocol and the offset.

Just add "TRANSPORT_INFO_IPv4" as another bitmask in the return value.
