From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Thu, 27 Mar 2014 15:19:08 -0700
Message-ID: <CAGVrzcbeVTT4W6kGQ7dWXC6Q5Z0LL0k=ENa3RzqBV9Ysq6iZ+A@mail.gmail.com>
References: <53330639.8050403@cumulusnetworks.com> <20140326165934.GH2869@minipsycho.orion>
 <CAGVrzcbBq2=DG198NnpSWu52+uuundqQ-6QiiuzHF5X_j8fcZw@mail.gmail.com>
 <20140326173536.GJ2869@minipsycho.orion> <CAGVrzca84nbsyG3ETvn4nkgpMtYTh_dFDbzCywSdQ9uJjLVOUg@mail.gmail.com>
 <20140326181436.GL2869@minipsycho.orion> <53334BDA.1060608@mojatatu.com>
 <CAGVrzcaconDBjgSfk0=6px2+6LbrxMkmesgigSa3-9WaK-LiOw@mail.gmail.com>
 <20140327065616.GA2845@minipsycho.orion> <CAHNKnsQYLNfkrC0088g2os30NcSz9HVzkytbK_qFbNfeSWkmFw@mail.gmail.com>
 <20140327165550.GN2845@minipsycho.orion> <CAHNKnsRrb1ZoV0he0jLjJ3TBRScHcs6XRxiXrscHRJ6X3=VuGQ@mail.gmail.com>
 <CAGVrzcZ5JpTZFTMkhLOoh8GMWPDitn=gsVkPLv7rpD3fH3kavQ@mail.gmail.com>
 <53349C6C.6050506@mojatatu.com> <CAGVrzcY5rhyu3KC2PQd0X+xdBB1D2yJhhPWntLRNoOhTSfDvoQ@mail.gmail.com>
 <53349F5C.8090205@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sergey Ryazanov <ryazanov.s.a@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
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
Received: from mail-pb0-f44.google.com ([209.85.160.44]:43917 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755633AbaC0WTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 18:19:49 -0400
Received: by mail-pb0-f44.google.com with SMTP id rp16so4117176pbb.3
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 15:19:48 -0700 (PDT)
In-Reply-To: <53349F5C.8090205@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-03-27 14:59 GMT-07:00 Jamal Hadi Salim <jhs@mojatatu.com>:
> On 03/27/14 17:54, Florian Fainelli wrote:
>>
>> 2014-03-27 14:47 GMT-07:00 Jamal Hadi Salim <jhs@mojatatu.com>:
>
>
>> I think it is. There is nothing in-tree that actually uses that
>> feature (switch chaining), but all the infrastructure is there to:
>>
>> - represent links between switches, which one is cascaded from which
>> one and get a sense of their addressing within the switch tree
>> - a function call to get that cascading table to programmed to each switch
>> - get all relevant "uplink/downlink" switch ports to be configured
>> appropriately
>>
>
> Sounds like we have a winner on this aspect at least.
> Is it a common setup to have such cascading though - or is this some
> overzelous way of solving cascading switches within a LAN?

It is fairly common for racked Ethernet switches that collect user
traffic in University campuses, or companies to be virtually assembled
into in big virtual switch which spans multiple physical switches
(Cisco's Flex Stack) as you minimize the number of uplinks. I would
guess that when Lennert designed DSA, he may have had this in mind,
for higher end Marvell Ethernet switch ASICs which could have
benefited that feature.

For the embedded space, I would say that this may happen from time to
time where you might cascade an internal switch to an external switch
which are of the same brand and speak the same tagging protocol.
-- 
Florian
