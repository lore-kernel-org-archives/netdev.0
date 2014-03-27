From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support
 of switch chip datapath
Date: Thu, 27 Mar 2014 17:55:19 -0400
Message-ID: <53349E47.9040407@mojatatu.com>
References: <5332677F.2090404@cumulusnetworks.com> <5332B1FE.7080102@mojatatu.com> <53330639.8050403@cumulusnetworks.com> <20140326165934.GH2869@minipsycho.orion> <CAGVrzcbBq2=DG198NnpSWu52+uuundqQ-6QiiuzHF5X_j8fcZw@mail.gmail.com> <20140326173536.GJ2869@minipsycho.orion> <CAGVrzca84nbsyG3ETvn4nkgpMtYTh_dFDbzCywSdQ9uJjLVOUg@mail.gmail.com> <20140326181436.GL2869@minipsycho.orion> <53334BDA.1060608@mojatatu.com> <CAGVrzcaconDBjgSfk0=6px2+6LbrxMkmesgigSa3-9WaK-LiOw@mail.gmail.com> <20140327065616.GA2845@minipsycho.orion> <CAHNKnsQYLNfkrC0088g2os30NcSz9HVzkytbK_qFbNfeSWkmFw@mail.gmail.com> <CAGVrzcaWQH0aH3HOFdhaX2K3sGkfn4EitWaN+17R1oU4xtudWg@mail.gmail.com> <CAHNKnsTs6o3bFr241Cj_=muGMgOq3fc9ZNXcBRt3M8+ccTJscA@mail.gmail.com> <CAGVrzcY=hxAf0eOoDfAAQZS1fNjFWbdY9Nbyuz6kFaOkSSis8w@mail.gmail.com>
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
Received: from mail-ob0-f169.google.com ([209.85.214.169]:43113 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756166AbaC0VzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 17:55:22 -0400
Received: by mail-ob0-f169.google.com with SMTP id va2so4975240obc.14
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 14:55:22 -0700 (PDT)
In-Reply-To: <CAGVrzcY=hxAf0eOoDfAAQZS1fNjFWbdY9Nbyuz6kFaOkSSis8w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/27/14 17:20, Florian Fainelli wrote:
> 2014-03-27 13:32 GMT-07:00 Sergey Ryazanov <ryazanov.s.a@gmail.com>:

>> I would like go further and suggest to consider a netdev that is
>> connected to the CPU switch port, as master. In case when we need to
>> perform some action on whole switch (e.g. dump FIB).
>
> This is what the 'sw1' net_device in Jiri's proposal would do.
>
>> And even name
>> switch ports, using master netdev name as prefix (e.g. eth1p0, eth1p1,
>> ..., eth1pN for ports of switch that is connected via eth1).
>
> I think the port naming using the switch abstract interface (sw1 here)
> is better because ports do belong to the switch.
>


Can we start calling whatever this netdev is something like "control"?
Or maybe it is "cpu" netdev? Since i am
comprehending better the need for such a special netdev, i would say:
if i do a "route add" and it needs to go to the specific switch,
the FIB entry will find its way to the "control" netdev which will
invoke device specific interfaces for the ASIC.
I would go as far as almost claiming - let this interface use netlink
definitions (we know how fib netlink interfaces look like already); 
caveat is: there may room  to tone it down.
Repeat and rinse for everything else we know how to do already

Of course there's a lot of evolution on the core code but thats
a different discussion.

cheers,
jamal
