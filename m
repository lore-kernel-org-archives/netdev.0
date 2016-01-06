From: Jesse Gross <jesse@kernel.org>
Subject: Re: [ovs-dev] [PATCH net 0/2] vxlan: Set a large MTU on ovs-created
 vxlan devices
Date: Wed, 6 Jan 2016 15:57:32 -0800
Message-ID: <CAEh+42iWSZOyikNydU2Bs8meqYfrKfUJLDGFJ8HzQ06k64LP0g@mail.gmail.com>
References: <1452087186-12926-1-git-send-email-david@weave.works>
 <20160106.155950.1007160228570301281.davem@davemloft.net> <8660z6qohn.fsf@weave.works>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, dev@openvswitch.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Wragg <david@weave.works>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:45254 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752585AbcAFX5t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 18:57:49 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 457C72017D
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 23:57:48 +0000 (UTC)
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6264820154
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 23:57:47 +0000 (UTC)
Received: by mail-qg0-f51.google.com with SMTP id b35so186001233qge.0
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 15:57:47 -0800 (PST)
In-Reply-To: <8660z6qohn.fsf@weave.works>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 6, 2016 at 3:25 PM, David Wragg <david@weave.works> wrote:
> David Miller <davem@davemloft.net> writes:
>>> Prior to 4.3, openvswitch vxlan vports could transmit vxlan packets of
>>> any size, constrained only by the ability to transmit the resulting
>>> UDP packets.  4.3 introduced vxlan netdevs corresponding to vxlan
>>> vports.  These netdevs have an MTU, which limits the size of a packet
>>> that can be successfully vxlan-encapsulated.  The default value for
>>> this MTU is 1500, which is awkwardly small, and leads to a conspicuous
>>> change in behaviour for userspace.
>>>
>>> These two patches set the MTU on openvswitch-crated vxlan devices to
>>> be 65465 (the maximum IP packet size minus the vxlan-on-IPv6
>>> overhead), effectively restoring the behaviour prior to 4.3.  In order
>>> to accomplish this, the first patch removes the MTU constraint of 1500
>>> for vxlan netdevs without an underlying device.
>>
>> Is this really the right thing to do?
>
> I'm certainly open to suggestions of better ways to solve the problem.

One option is to simply set the MTU on the device from userspace.

The reality is that the code you're modifying is compatibility code.
Maybe we should make this change to preserve the old behavior for old
callers (although, again, it should not be just for VXLAN). But no new
features or tunnel types will be supported in this manner.

New or updated userspace programs should work by simply creating and
adding tunnel devices to OVS. That won't go through this path at all
so you're going to need to find another approach in the near future in
any case.
