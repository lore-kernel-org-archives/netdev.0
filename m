From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: bonding (IEEE 802.3ad) not working with qemu/virtio
Date: Sat, 30 Jan 2016 12:34:11 +0100
Message-ID: <20160130113411.GA2181@nanopsycho.orion>
References: <56ABDA3D.8040100@cumulusnetworks.com>
 <28285.1454103900@famine>
 <56ABDE2A.7010301@cumulusnetworks.com>
 <20160129.225924.1343743091073159760.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nikolay@cumulusnetworks.com, jay.vosburgh@canonical.com,
	bjornar.ness@gmail.com, netdev@vger.kernel.org, vfalico@gmail.com,
	gospo@cumulusnetworks.com, mst@redhat.com,
	virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36428 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751945AbcA3LeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2016 06:34:14 -0500
Received: by mail-wm0-f65.google.com with SMTP id 128so1681557wmz.3
        for <netdev@vger.kernel.org>; Sat, 30 Jan 2016 03:34:13 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160129.225924.1343743091073159760.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Jan 30, 2016 at 07:59:24AM CET, davem@davemloft.net wrote:
>From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>Date: Fri, 29 Jan 2016 22:48:26 +0100
>
>> On 01/29/2016 10:45 PM, Jay Vosburgh wrote:
>>> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
>>>=20
>>>> On 01/25/2016 05:24 PM, Bj=F8rnar Ness wrote:
>>>>> As subject says, 802.3ad bonding is not working with virtio netwo=
rk model.
>>>>>
>>>>> The only errors I see is:
>>>>>
>>>>> No 802.3ad response from the link partner for any adapters in the=
 bond.
>>>>>
>>>>> Dumping the network traffic shows that no LACP packets are sent f=
rom the
>>>>> host running with virtio driver, changing to for example e1000 so=
lves
>>>>> this problem
>>>>> with no configuration changes.
>>>>>
>>>>> Is this a known problem?
>>>>>
>>>> [Including bonding maintainers for comments]
>>>>
>>>> Hi,
>>>> Here's a workaround patch for virtio_net devices that "cheats" the
>>>> duplex test (which is the actual problem). I've tested this locall=
y
>>>> and it works for me.
>>>> I'd let the others comment on the implementation, there're other s=
igns
>>>> that can be used to distinguish a virtio_net device so I'm open to=
 suggestions.
>>>> Also feedback if this is at all acceptable would be appreciated.
>>>=20
>>> 	Should virtio instead provide an arbitrary speed and full duplex
>>> to ethtool, as veth does?
>>>=20
>>> 	Creating a magic whitelist of devices deep inside the 802.3ad
>>> implementation seems less desirable.
>>>=20
>> TBH, I absolutely agree. In fact here's what we've been doing:
>> add set_settings which allows the user to set any speed/duplex
>> and get_settings of course to retrieve that. This is also useful
>> for testing other stuff that requires speed and duplex, not only
>> for the bonding case.
>
>I also agree.  Having a whitelist is just rediculous.
>
>There should be a default speed/duplex setting for such devices as wel=
l.
>We can pick one that will be use universally for these kinds of device=
s.

Exposing made up speed for veth and virtio_net sounds odd to me. User
see 10000Mb/s but it makes no sense at all. It is just confusing.

I believe this is bonding bug and should be fixed in there. Team works
fine with virtio_net device and lacp runner.
