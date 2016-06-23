From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Subject: Re: [patch net-next v5 0/4] return offloaded stats as default and
 expose original sw stats
Date: Thu, 23 Jun 2016 08:11:26 -0700
Message-ID: <CACcJQnTfr5n75q48aJQ3bwzfCd9oThTCHcR_qWG7R9aV13pOQw@mail.gmail.com>
References: <1466522156-4795-1-git-send-email-jiri@resnulli.us>
 <CAJieiUgP3j=W=khq_q-y382eFurHQSCs_Td8Q_KHtru6La22XA@mail.gmail.com>
 <20160623054050.GA2060@nanopsycho.orion> <576BC7A7.2000704@cumulusnetworks.com>
 <20160623113508.GE2060@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Nogah Frankel <nogahf@mellanox.com>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Yotam Gigi <yotamg@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>, sd@queasysnail.net,
	eranbe@mellanox.com, Alexei Starovoitov <ast@plumgrid.com>,
	Eric Dumazet <edumazet@google.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	David Ahern <dsa@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:34110 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874AbcFWPMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 11:12:07 -0400
Received: by mail-qk0-f180.google.com with SMTP id t127so110627115qkf.1
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2016 08:12:06 -0700 (PDT)
In-Reply-To: <20160623113508.GE2060@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>> we can't separate CPU and HW stats there. In some cases (or ASICs) HW
>>>> counters do
>>>> not include CPU generated packets....you will have to add CPU
>>>> generated pkt counters to the
>>>> hw counters for such virtual device stats.
>>> Can you please provide and example how that could happen?
>>
>>example is the bridge vlan stats I mention below. These are usually counted
>>by attaching hw virtual counter resources. And CPU generated packets
>>in some cases maybe setup to bypass the ASIC pipeline because the CPU
>>has already made the required decisions. So, they may not be counted by
>>by such hw virtual counters.
>
> Bypass ASIC? How do the packets get on the wire?
>

Bypass the "forwarding pipeline" in the ASIC that is. Obviously the
ASIC ships the CPU generated packet out of the switch/front-panel
port. Continuing Roopa's example of vlan netdev stats.... To get the
HW stats counters are typically tied to the ingress and egress vlan hw
entries. All the incoming packets are subject to the ingress vlan
lookup irrespective of whether they get punted to the CPU or whether
they are forwarded to another front panel port. In that case the
ingress HW stats does represent all packets. However for CPU
originated packets egress vlan lookups are bypassed in the ASIC (this
is common forwarding option in most ASICs) and the packet shipped as
is out of front-panel port specified by the CPU. Which means these
packets will NOT be counted against the egress VLAN HW counter; hence
the need for summation.
