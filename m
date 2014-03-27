From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support
 of switch chip datapath
Date: Thu, 27 Mar 2014 17:41:59 -0400
Message-ID: <53349B27.7070501@mojatatu.com>
References: <5332677F.2090404@cumulusnetworks.com> <5332B1FE.7080102@mojatatu.com> <53330639.8050403@cumulusnetworks.com> <20140326165934.GH2869@minipsycho.orion> <CAGVrzcbBq2=DG198NnpSWu52+uuundqQ-6QiiuzHF5X_j8fcZw@mail.gmail.com> <20140326173536.GJ2869@minipsycho.orion> <CAGVrzca84nbsyG3ETvn4nkgpMtYTh_dFDbzCywSdQ9uJjLVOUg@mail.gmail.com> <20140326181436.GL2869@minipsycho.orion> <53334BDA.1060608@mojatatu.com> <CAGVrzcaconDBjgSfk0=6px2+6LbrxMkmesgigSa3-9WaK-LiOw@mail.gmail.com> <20140327065616.GA2845@minipsycho.orion> <CAHNKnsQYLNfkrC0088g2os30NcSz9HVzkytbK_qFbNfeSWkmFw@mail.gmail.com> <CAGVrzcaWQH0aH3HOFdhaX2K3sGkfn4EitWaN+17R1oU4xtudWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
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
To: Florian Fainelli <f.fainelli@gmail.com>,
	Sergey Ryazanov <ryazanov.s.a@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:57435 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755359AbaC0VmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 17:42:04 -0400
Received: by mail-ob0-f169.google.com with SMTP id va2so5015574obc.0
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 14:42:03 -0700 (PDT)
In-Reply-To: <CAGVrzcaWQH0aH3HOFdhaX2K3sGkfn4EitWaN+17R1oU4xtudWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I should probably be reading emails backward to catchup, but this
one caught my eye.

On 03/27/14 12:41, Florian Fainelli wrote:

> It duplicates the information when things just work fine, consider an
> external switch connected via RGMII to a CPU Ethernet MAC, you might
> want to get statistics from both sides (the switch CPU port and the
> CPU Ethernet MAC) to diagnose why things are not working as expected,
> which unfortunately happens once in a while with RGMII.
>
> If we expose both net_device, we will be able to retrieve statistics
> about from both sides, without resorting to ad-hoc debugging tools,
> but maybe this is not worth the effort.
>

This is probably the most convincing rationale i have seen
for this netdev. I think the abstraction is what was bothering me
earlier from Jiri's patch. It is not a "master" netdev of the switch
(since a switch port can only be attached to one master),
it is closer to a "conduit" netdev Roopa was alluding to. From
abstraction you dont attach ports to it, it comes with ports - but it is
merely the control for those ports. Would refereing to this port as
"control" be a good way to go forward?
So if i wanted to retrieve hardware stats for sw1p0 i look up its
"control"->dev->somendo and pass it enough information to give me
the hardware stats for sw1p0.
I can see the rate control Sergey is refering to as merely a tc
ingress policer attached on it (which may translate to some hardware
register setting).
Likewise this is probably where my query to "tell me how many
fdb entries you can support" ends up.

>> So there are no reasons
>> to force user to configure this port manually, and automatic
>> configuration of CPU switch port without exporting them as netdev
>> seems as good approach.
>
> Well, maybe that's the answer, since we know that e.g: sw1p3 is always
> connected to e.g: eth0, we could create an automatic bridge between
> those two, this would keep the netdev exposure to user-space, but an
> user would not have to know about that specific detail to get things
> to work.
>

Could ifconfig down of this port have some semantic that nothing comes
to the cpu?

cheers,
jamal
