From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: bonding (IEEE 802.3ad) not working with qemu/virtio
Date: Fri, 29 Jan 2016 13:45:00 -0800
Message-ID: <28285.1454103900@famine>
References: <CAJO99TmB3957Wq3Cse7azgBxKeZ2BV6QihoyAsjUjyvzc-V8dQ@mail.gmail.com> <56ABDA3D.8040100@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?us-ascii?Q?=3D=3FUTF-8=3FQ=3FBj=3Dc3=3Db8rnar=5FNess=3F=3D?=
	<bjornar.ness@gmail.com>, netdev <netdev@vger.kernel.org>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:39719 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757030AbcA2VpF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 16:45:05 -0500
In-reply-to: <56ABDA3D.8040100@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

>On 01/25/2016 05:24 PM, Bj=C3=B8rnar Ness wrote:
>> As subject says, 802.3ad bonding is not working with virtio network =
model.
>>=20
>> The only errors I see is:
>>=20
>> No 802.3ad response from the link partner for any adapters in the bo=
nd.
>>=20
>> Dumping the network traffic shows that no LACP packets are sent from=
 the
>> host running with virtio driver, changing to for example e1000 solve=
s
>> this problem
>> with no configuration changes.
>>=20
>> Is this a known problem?
>>=20
>[Including bonding maintainers for comments]
>
>Hi,
>Here's a workaround patch for virtio_net devices that "cheats" the
>duplex test (which is the actual problem). I've tested this locally
>and it works for me.
>I'd let the others comment on the implementation, there're other signs
>that can be used to distinguish a virtio_net device so I'm open to sug=
gestions.
>Also feedback if this is at all acceptable would be appreciated.

	Should virtio instead provide an arbitrary speed and full duplex
to ethtool, as veth does?

	Creating a magic whitelist of devices deep inside the 802.3ad
implementation seems less desirable.

	-J
=09
---
	-Jay Vosburgh, jay.vosburgh@canonical.com
