From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: Second ethernet on kirkwood does not work when probed through
 DT
Date: Sun, 07 Jul 2013 13:36:51 +0200
Message-ID: <51D952D3.8070401@gmail.com>
References: <20130706215426.6e666d6af0dc6c9ea5fe32cd@openwrt.org> <51D88A8E.1060104@gmail.com> <20130706233912.00004044@unknown> <51D94884.4000204@gmail.com> <20130707132607.00007188@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Florian Fainelli <florian@openwrt.org>,
	Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>
To: Jonas Gorski <jogo@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:46449 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692Ab3GGLg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jul 2013 07:36:58 -0400
In-Reply-To: <20130707132607.00007188@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/07/2013 01:26 PM, Jonas Gorski wrote:
> On Sun, 07 Jul 2013 12:52:52 +0200
> Sebastian Hesselbarth<sebastian.hesselbarth@gmail.com>  wrote:
>> The error below is a naming issue for the port. As there is only one
>> port per controller, both reg properties of the port nodes of
>> kirkwood.dtsi have to be<0>  as they determine the register offset
>> within the controller registers. As mentioned before, KW has a
>> dual-controller, single port configuration.
>>
>> So the wrong reg property in kirkwood.dtsi is a bug and I will update
>> the patch.
>>
>> Second, mv643xx_eth as in net-next does a
>> platform_device_alloc(MV643XX_ETH_NAME, ppd.port_number)
>> which will cause two devices named mv643xx_eth_port.0 if you change
>> both of the reg property to<0>.
>>
>> A quick fix would be to change the above to
>> platform_device_alloc(pnp->name, ppd.port_number)
>> so the port devices will be named after the device nodes name.
>>
>> Also, for this I will prepare a patch. But the rename of the port
>> devices could again raise the clock gating/loosing MAC issue.
>
> In my case it's a non-issue as the studid D-Link U-Boot doesn't even
> setup a mac for eth1, so there's nothing to lose ;).
>
>> (I know again, why I hate this shared/port separation of mv643xx_eth)
>>
>> Anyway, can you please try to have both ports reg properties set
>> to<0>, with nodes named ethernet0-port@0 and ethernet1-port@0,
>> and the platform_device_alloc in mv643xx_eth modified?
>
> In addition I added a static counter for the allocated devs (to not
> overwrite the pointers in port_platdev[]).

Ok, but that is not required to make it work, is it? IMHO we should
honor what is passed by reg property, even it will be always zero
for KW and the other Orion SoCs. Otherwise, we would implicitly put
the numbering in the order of port nodes.

> That seems to work, as now eth1 comes up and works (successfully got a
> IP through DHCP).

Ok, great. Will prepare a fix for mv643xx_eth on top of net-next. And
an update of the kirkwood conversion patches.

Sebastian
