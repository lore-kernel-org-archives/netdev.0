From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Wed, 26 Mar 2014 16:16:04 -0700
Message-ID: <CAGVrzcZ+y85YQuf=HyPwgXw1daCqEDhVPbo3vm_9VdvDL=gZoA@mail.gmail.com>
References: <20140325180009.GB15723@casper.infradead.org> <20140325193533.GF8102@hmsreliant.think-freely.org>
 <CAGVrzcbRggJV+5+EuZnXVoU+qdK9ugPRL+J-mp-UraGuo19jnQ@mail.gmail.com>
 <5332677F.2090404@cumulusnetworks.com> <5332B1FE.7080102@mojatatu.com>
 <53330639.8050403@cumulusnetworks.com> <20140326165934.GH2869@minipsycho.orion>
 <CAGVrzcbBq2=DG198NnpSWu52+uuundqQ-6QiiuzHF5X_j8fcZw@mail.gmail.com>
 <20140326173536.GJ2869@minipsycho.orion> <CAGVrzca84nbsyG3ETvn4nkgpMtYTh_dFDbzCywSdQ9uJjLVOUg@mail.gmail.com>
 <20140326181436.GL2869@minipsycho.orion> <53334BDA.1060608@mojatatu.com>
 <CAGVrzcaconDBjgSfk0=6px2+6LbrxMkmesgigSa3-9WaK-LiOw@mail.gmail.com> <53335A7F.8010801@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Felix Fietkau <nbd@openwrt.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:36034 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756166AbaCZXQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 19:16:44 -0400
Received: by mail-pd0-f171.google.com with SMTP id r10so2517658pdi.2
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 16:16:44 -0700 (PDT)
In-Reply-To: <53335A7F.8010801@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-03-26 15:53 GMT-07:00 Jamal Hadi Salim <jhs@mojatatu.com>:
> On 03/26/14 18:22, Florian Fainelli wrote:
>>
>> 2014-03-26 14:51 GMT-07:00 Jamal Hadi Salim <jhs@mojatatu.com>:
>
>
>>
>> eth0 corresponds to a CPU Ethernet MAC facing e.g: sw1p3 switch port.
>> It is "regular" Ethernet driver connected to the switch without
>> switch-specific logic. The goal is twofold:
>>
>> - allow any regular Ethernet driver to be connected to an external
>> switch via e.g: MDIO/MDC or other without specific switch knowledge
>> - represents accurately how the hardware is designed/connected
>>
>
> Gah. Sorry - I missed the MII interface.
> In such a case as shown here then, how do you control sw1p0-3?

Most switches expose individual ports as individual PHY addresses
either on the same MDIO bus the Ethernet MAC is connected to the
switch, or an internal one which is accessible through a special PHY
address on the "regular" MDIO bus. Ports 0-3 are accessible
individually at MDIO addresses 0-3 and the special CPU port has a
special PHY address e.g: 16 for Marvell, 30 for Broadcom, which
delivers register access to global and per-port configuration
registers. For memory-mapped switches, well, you get per-port register
ranges, so this is much simpler.

ethtool would be the user-interface to talk individually to these
ports here, and the DSA driver just goes talk to the individual port
through MDIO to get their port status (right now it regularly polls
for the port link status/duplex/speed).

>
>
>> but maybe, we can simplify and have e.g: sw1p3 and eth0 be the same
>> interface...
>
>
> It sounds to me the CPU side is only a driver for sw1p3.

I think what I had in mind when I wrote that part of the mail is some
special hardware here on which the CPU Ethernet MAC output queues do
not have a 1:1 mapping to the corresponding switch egress port output
queues, but I think you are right.

>
>
>>>
>>> Note: even the high end chips tend to have the concept of a "cpu port"
>>> but my experience is to hide that as part of the switch driver.
>
>
> Note: the high end devices "cpu ports" are accessible typically
> via PCIE interfaces for control and some DMA for data activity.
>
> cheers,
> jamal
>
>



-- 
Florian
