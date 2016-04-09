From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net-next 1/6] net: Make vxlan/geneve default udp ports public
Date: Sat, 9 Apr 2016 18:48:32 -0300
Message-ID: <CAEh+42jw8c2E1wOCF9DCa3rHL8f8+8ptdTy0QU-xYKmxPDRiZQ@mail.gmail.com>
References: <1460207825-3622-1-git-send-email-manish.chopra@qlogic.com>
 <1460207825-3622-2-git-send-email-manish.chopra@qlogic.com>
 <CAEh+42j+y=cKUDNMQrPdHTozz5=P9pmbQOyKir6DOf=wDJvHSg@mail.gmail.com> <BLUPR11MB011432C1D124F762CC278E9E93920@BLUPR11MB0114.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: Manish Chopra <manish.chopra@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:37955 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752953AbcDIVsv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Apr 2016 17:48:51 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id CC2312026D
	for <netdev@vger.kernel.org>; Sat,  9 Apr 2016 21:48:49 +0000 (UTC)
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C1F532022D
	for <netdev@vger.kernel.org>; Sat,  9 Apr 2016 21:48:47 +0000 (UTC)
Received: by mail-qg0-f49.google.com with SMTP id f105so93587269qge.2
        for <netdev@vger.kernel.org>; Sat, 09 Apr 2016 14:48:47 -0700 (PDT)
In-Reply-To: <BLUPR11MB011432C1D124F762CC278E9E93920@BLUPR11MB0114.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 9, 2016 at 5:46 PM, Manish Chopra <manish.chopra@qlogic.com> wrote:
>> -----Original Message-----
>> From: Jesse Gross [mailto:jesse@kernel.org]
>> Sent: Saturday, April 09, 2016 9:36 PM
>> To: Manish Chopra <manish.chopra@qlogic.com>
>> Cc: David Miller <davem@davemloft.net>; netdev <netdev@vger.kernel.org>;
>> Ariel Elior <Ariel.Elior@qlogic.com>; Yuval Mintz <Yuval.Mintz@qlogic.com>
>> Subject: Re: [PATCH net-next 1/6] net: Make vxlan/geneve default udp ports
>> public
>>
>> On Sat, Apr 9, 2016 at 10:17 AM, Manish Chopra <manish.chopra@qlogic.com>
>> wrote:
>> > Rationale behind this change is that with some OVS configuration
>> > UDP ports doesn't get notified to the driver using
>> > .ndo_[add|del]_vxlan_port. So for the driver to work with
>> > these specific ports in that environment we need to have them configured
>> > on adapter by default for the required hardware offload support.
>>
>> I think you are referring to old out of tree code - no version of
>> upstream OVS does this. In addition, any old code won't work against
>> the new kernels that would include this driver update anyways so there
>> won't be a benefit in any case.
>>
>> Please just use the normal registration mechanism that is already
>> exposed. I also noticed that in the Geneve case you aren't currently
>> registering for port notifications and just using the assigned port
>> number in all cases, which isn't right.
>
> In the past I have tried openvswitch release package [V2.4.0] from openvswitch.org
> http://openvswitch.org/releases/
>
> I have tried configuring ovs there on some redhat 7.x kernel with above mentioned package utility "ovs-vsctl" where ports were not notified to drivers.
> Till earlier versions of openvswitch package [V2.3.2] - It was fine and UDP ports were used to be notified to the driver
>
> I thought that the same [No port config notification to the drivers] problem would be with latest upstream OVS,  isn't it ? which is why configuration of at least default ports is done by default in drivers.
> For upstream OVS, is there any other openvswitch package used ? Can't the above release package be used over net-next/upstream kernel ?

There was a bug in code that was backported for use with older kernels
that prevented notifications from happening to the drivers. This is
fixed in the most recent version. In addition, this was never present
in the original code that is part of the upstream kernel. All versions
of userspace are compatible with all kernel modules, regardless of how
they were released.

> If latest OVS notifies to configure UDP ports to the driver - I would simply skip default ports configuration by default and instead use .ndo_[add|del]_xxxx for both vxlan and geneve.

That would be great, thanks.
