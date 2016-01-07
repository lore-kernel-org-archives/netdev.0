From: David Wragg <david@weave.works>
Subject: Re: [PATCH net 0/2] vxlan: Set a large MTU on ovs-created vxlan devices
Date: Thu, 07 Jan 2016 23:42:52 +0000
Message-ID: <86d1tdot1f.fsf@weave.works>
References: <1452087186-12926-1-git-send-email-david@weave.works>
	<20160106.155950.1007160228570301281.davem@davemloft.net>
	<8660z6qohn.fsf@weave.works>
	<20160107.164746.548558171283936394.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:32836 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753427AbcAGXm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 18:42:56 -0500
Received: by mail-wm0-f49.google.com with SMTP id f206so117109160wmf.0
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 15:42:55 -0800 (PST)
In-Reply-To: <20160107.164746.548558171283936394.davem@davemloft.net> (David
	Miller's message of "Thu, 07 Jan 2016 16:47:46 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:
>> Considering non-openvswitch scenarios, when using vxlan netdevs
>> directly, a vxlan netdev locked to an underlying device supporting jumbo
>> frames can use a larger MTU.  It's only vxlan netdevs without an
>> underlying device that have the limit of 1500 imposed.  But why
>> shouldn't there be the same flexibility to select an MTU for best
>> performance in both cases?  Aren't the fragmentation concerns the same?
>
> When there is an underlying device, there are no fragmentation concerns
> and PMTU will function properly because the MTU will be set
> accurately.

I can see how that works in the case where the vxlan endpoints are on
the same subnet of the underlying network.  But in the general case, the
"accurate" vxlan MTU to avoid fragmentation concerns should correspond
to the path MTU between the endpoints.  How does knowing an underlying
device help with that?  It's reasonable to calculate a default MTU for
the vxlan device based on an underlying device, if one is specified.
But unless the endpoints are on the same subnet, that's just a guess.

(In the case of our application, we have openvswitch configured to set
DF on the vxlan packets.  So we know we are not getting inadvertent
fragmentation.)

>> True.  But in what sense is 1500 accurate?  Uses/users of the kernel
>> openvswitch code have always had to get this right, making sure that
>> the MTU set on a vxlan overlay network conforms to the underlying
>> network paths involved.
>
> "right" is a subjective thing.
>
> Here, once again, the poorly thought out amount of flexibility
> openvswitch provides is going to have a serious negative consequence
> for our implementation.
>
> I'm really tired of seeing this happen over and over again.
> Openvswitch's growth and the expansion of it's feature set was
> extremely poorly managed.

I'm sorry that there is some angst around the openvswitch kernel
subsystem.  I wasn't involved in its development, so I have no strong
opinion on those issues.  But we use it in our application, and we'd
like to find a way to restore the ability to perform vxlan encapsulation
of packets greater than 1500 bytes from openvswitch, as we could prior
to 4.3.

Is there another path to that same goal that is less contentious than my
proposal?

I'm willing to follow up on Jesse's request to look into the other
tunnel types too, but at the moment I'm wondering what the chances are
that the resulting submission would get accepted.

David
