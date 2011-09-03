From: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Subject: Re: [PATCH 1/2] bridge: leave carrier on for empty bridge
Date: Sat, 03 Sep 2011 11:15:41 +0900
Message-ID: <4E618DCD.5070901@sfc.wide.ad.jp>
References: <20110902172220.830228928@vyatta.com> <20110902172247.396753508@vyatta.com> <4E614CF7.7030700@gmail.com> <20110902151100.327af0bf@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Achmad Basuki <abazh@sfc.wide.ad.jp>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:55887 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753114Ab1ICCPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 22:15:46 -0400
In-Reply-To: <20110902151100.327af0bf@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/09/11 07:11, Stephen Hemminger wrote:
> On Fri, 02 Sep 2011 23:39:03 +0200
> Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com> wrote:
>
>> Le 02/09/2011 19:22, Stephen Hemminger a =E9crit :
>>> This resolves a regression seen by some users of bridging.
>>> Some users use the bridge like a dummy device.
>>> They expect to be able to put an IPv6 address on the device
>>> with no ports attached during boot.
>>>
>>> Note: the bridge still will reflect the state of ports in the
>>> bridge if there are any added.

Guilty as charged :) It's a valid use case in libvirtd. Thanks for the =
patch. I've tried your patch.
It doesn't work. There is still no carrier. Thing still break. The whol=
e of commit
1faa4356a including the part where liveports is used to toggle carrier =
has to be reverted. Otherwise, it doesn't work.
I've tried that on my machine.

>> Doesn't this jeopardize the behavior introduced in 1faa4356a3bd89ea1=
1fb92752d897cff3a20ec0e
>> "bridge: control carrier based on ports online"?
>>
>> If the user starts the DHCP client before adding the first port to t=
he bridge, the DHCP client will=20
>> have a carrier and start the autoconfiguration process. This was the=
 old behavior, but you fixed it.
>>
>> 	Nicolas.
>>
> There is no perfect solution.
> If DHCP works then IPv6 breaks?

A more ideal solution in this case is to add the option to enabling car=
rier on sysfs and modify libvirtd
to turn on the carrier if IPv6 is enabled. But it will still break the =
existing configuration until everyone
upgrade to the latest libvirtd and kernel. Since there is no other comp=
lain from other user with this setup,
I guess nobody actually assigns IPv6 to libvirtd network device at this=
 moment (partly because virt-manager
doesn't expose that functionality yet??).

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
