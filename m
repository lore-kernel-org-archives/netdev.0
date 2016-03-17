From: Samuel Gauthier <samuel.gauthier@6wind.com>
Subject: Re: [PATCH net-next 0/2] ovs: refresh a flow via netlink
Date: Thu, 17 Mar 2016 17:24:57 +0100
Message-ID: <CAMEOZh+TR3S+30e+u9yVH04XN2Z26WEnhNK=t7DFq8YaBmjFyA@mail.gmail.com>
References: <1458140872-22438-1-git-send-email-samuel.gauthier@6wind.com>
	<CAEh+42jMSpPr8yUmmO355D=auKa-cGTwOZu0CSf-0=rczu4zwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pravin Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:36293 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933971AbcCQQY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 12:24:59 -0400
Received: by mail-io0-f178.google.com with SMTP id g184so48172119ioa.3
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 09:24:58 -0700 (PDT)
In-Reply-To: <CAEh+42jMSpPr8yUmmO355D=auKa-cGTwOZu0CSf-0=rczu4zwg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-03-17 0:23 GMT+01:00 Jesse Gross <jesse@kernel.org>:
> On Wed, Mar 16, 2016 at 8:07 AM, Samuel Gauthier
> <samuel.gauthier@6wind.com> wrote:
>> This patchset adds a netlink api to refresh an existing flow in
>> openvswitch.
>>
>> When a packet is sent in the openvswitch kernel datapath and no
>> flow is found, the packet is sent to the ovs-vswitchd daemon,
>> which will process the packet, and ask the kernel to create a new
>> flow. The next packets for this flow will be processed by the
>> kernel datapath. If a flow is not used for a (configurable)
>> period of time, ovs-vswitchd removes the flow from the kernel.
>>
>> As a result, it can be tricky to test the kernel datapath against
>> packets, as the first packets of each flow will have to go
>> through the ovs-vswitchd daemon. For instance, to do a zeroloss
>> performance test, you establish the flows, and then you have to
>> perform your zeroloss test before the flow is removed by
>> ovs-vswitchd.
>>
>> It is possible to configure a flow timeout in ovs-vswitchd (using
>> other_config:max-idle option), but it changes the behavior for
>> all the flows, which is not always what you want.
>
> It seems to me that it would be preferable to implement the necessary
> behavior in userspace to handle this directly. The logic that is
> removing the flow is in userspace, so rather than asking the kernel to
> lie about the current state of things, we can just modify the logic to
> handle this case.

It seemed like a problem limited to the kernel datapath (i.e.: not to
the other ovs datapaths), so it made sense to me to fix it by a
netlink API.
The idea was to do something similar to the OVS_FLOW_ATTR_CLEAR
attribute (which sets the flow statistics and used field to 0).

This said, I could have a look to a pure userland solution, but I am
not sure how to do it. Could you elaborate what you have in mind?

Thanks.
