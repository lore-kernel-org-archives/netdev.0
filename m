From: David Wragg <david@weave.works>
Subject: Re: [PATCH net 1/2] vxlan: Relax the MTU constraint on vxlan devices
Date: Thu, 07 Jan 2016 11:31:38 +0000
Message-ID: <86lh81pqw5.fsf@weave.works>
References: <1452087186-12926-1-git-send-email-david@weave.works>
	<1452087186-12926-2-git-send-email-david@weave.works>
	<20160107112414.GH32456@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:38613 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752246AbcAGLbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 06:31:41 -0500
Received: by mail-wm0-f49.google.com with SMTP id b14so118439567wmb.1
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 03:31:40 -0800 (PST)
In-Reply-To: <20160107112414.GH32456@pox.localdomain> (Thomas Graf's message
	of "Thu, 7 Jan 2016 12:24:14 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf <tgraf@suug.ch> writes:
>> +	int max_mtu = 65535;
>
> This should probably be represented as a new const DEV_MAX_MTU which
> can be used by veth, tun, and virtio as well instead of hardcoding
> this separately in each driver.

I discovered IP_MAX_MTU in net/route.h after putting the patch together.
Seems appropriate to use that?

>> +static int vxlan_change_mtu(struct net_device *dev, int new_mtu)
>> +{
>> +	struct vxlan_dev *vxlan = netdev_priv(dev);
>> +	struct vxlan_rdst *dst = &vxlan->default_dst;
>> +	struct net_device *lowerdev = __dev_get_by_index(vxlan->net,
>> +							 dst->remote_ifindex);
>> +	return __vxlan_change_mtu(dev, lowerdev, dst, new_mtu);
>
> Any particular reason for the indirection?

To make patch 2/2 simpler.  I can rearrange to eliminate the indirection
here if that is preferred.

David
