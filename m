From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: bonding (IEEE 802.3ad) not working with qemu/virtio
Date: Fri, 29 Jan 2016 22:48:26 +0100
Message-ID: <56ABDE2A.7010301@cumulusnetworks.com>
References: <CAJO99TmB3957Wq3Cse7azgBxKeZ2BV6QihoyAsjUjyvzc-V8dQ@mail.gmail.com>
 <56ABDA3D.8040100@cumulusnetworks.com> <28285.1454103900@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Bj=c3=b8rnar_Ness?= <bjornar.ness@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:38797 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756697AbcA2Vs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 16:48:29 -0500
Received: by mail-wm0-f43.google.com with SMTP id p63so85510206wmp.1
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 13:48:28 -0800 (PST)
In-Reply-To: <28285.1454103900@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/29/2016 10:45 PM, Jay Vosburgh wrote:
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
>=20
>> On 01/25/2016 05:24 PM, Bj=C3=B8rnar Ness wrote:
>>> As subject says, 802.3ad bonding is not working with virtio network=
 model.
>>>
>>> The only errors I see is:
>>>
>>> No 802.3ad response from the link partner for any adapters in the b=
ond.
>>>
>>> Dumping the network traffic shows that no LACP packets are sent fro=
m the
>>> host running with virtio driver, changing to for example e1000 solv=
es
>>> this problem
>>> with no configuration changes.
>>>
>>> Is this a known problem?
>>>
>> [Including bonding maintainers for comments]
>>
>> Hi,
>> Here's a workaround patch for virtio_net devices that "cheats" the
>> duplex test (which is the actual problem). I've tested this locally
>> and it works for me.
>> I'd let the others comment on the implementation, there're other sig=
ns
>> that can be used to distinguish a virtio_net device so I'm open to s=
uggestions.
>> Also feedback if this is at all acceptable would be appreciated.
>=20
> 	Should virtio instead provide an arbitrary speed and full duplex
> to ethtool, as veth does?
>=20
> 	Creating a magic whitelist of devices deep inside the 802.3ad
> implementation seems less desirable.
>=20
TBH, I absolutely agree. In fact here's what we've been doing:
add set_settings which allows the user to set any speed/duplex
and get_settings of course to retrieve that. This is also useful
for testing other stuff that requires speed and duplex, not only
for the bonding case.

I'll add the virtio_net maintainers to the discussion, see if it's
okay with everyone and I'll move to send patches once net-next opens up=
=2E

Thanks!


> 	-J
> =09
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com
>=20
