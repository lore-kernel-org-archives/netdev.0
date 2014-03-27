From: Sergey Ryazanov <ryazanov.s.a@gmail.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Thu, 27 Mar 2014 18:10:24 +0400
Message-ID: <CAHNKnsQYLNfkrC0088g2os30NcSz9HVzkytbK_qFbNfeSWkmFw@mail.gmail.com>
References: <5332677F.2090404@cumulusnetworks.com> <5332B1FE.7080102@mojatatu.com>
 <53330639.8050403@cumulusnetworks.com> <20140326165934.GH2869@minipsycho.orion>
 <CAGVrzcbBq2=DG198NnpSWu52+uuundqQ-6QiiuzHF5X_j8fcZw@mail.gmail.com>
 <20140326173536.GJ2869@minipsycho.orion> <CAGVrzca84nbsyG3ETvn4nkgpMtYTh_dFDbzCywSdQ9uJjLVOUg@mail.gmail.com>
 <20140326181436.GL2869@minipsycho.orion> <53334BDA.1060608@mojatatu.com>
 <CAGVrzcaconDBjgSfk0=6px2+6LbrxMkmesgigSa3-9WaK-LiOw@mail.gmail.com> <20140327065616.GA2845@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
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
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:61165 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754971AbaC0OKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 10:10:44 -0400
Received: by mail-yk0-f169.google.com with SMTP id 142so2325765ykq.14
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 07:10:44 -0700 (PDT)
In-Reply-To: <20140327065616.GA2845@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

sorry for the intrusion, but let me place my 2 cents.

2014-03-27 10:56 GMT+04:00 Jiri Pirko <jiri@resnulli.us>:
> Wed, Mar 26, 2014 at 11:22:51PM CET, f.fainelli@gmail.com wrote:
>>2014-03-26 14:51 GMT-07:00 Jamal Hadi Salim <jhs@mojatatu.com>:
>>> On 03/26/14 14:14, Jiri Pirko wrote:
>>>>
>>>> Wed, Mar 26, 2014 at 06:58:32PM CET, f.fainelli@gmail.com wrote:
>>>>>
>>>>> 2014-03-26 10:35 GMT-07:00 Jiri Pirko <jiri@resnulli.us>:
>>>
>>>
>>>
>>>>> You are right, sw1p0 and sw1p1 were meant to be, say LAN ports in my
>>>>> example.
>>>>>
>>>>> I think there is an implicit convention that sw1 represents the
>>>>> Ethernet switch port connected to the CPU Ethernet MAC, and that it is
>>>>> always connected, hence there is no need to create a "fake" bridge to
>>>>> link sw1 to eth0 for instance?
>>>>
>>>>
>>>> I think you are kind of mixing apples and oranges (or I might be I'm not
>>>> understanding you correctly).
>>>> This is how I see it, sticking to the names you use in the example:
>>>>
>>>>              (sw1) (abstract place-holder netdev)
>>>>            --------
>>>>           switch chip                   CPU
>>>>     -----------------------            ------
>>>>     sw1p0 sw1p1 sw1p2 sw1p3             eth0
>>>>       |     |     |     |                |
>>>>      PHY   PHY   PHY    ------someMII-----
>>>>
>>>> You see that eth0 is the CPU part of the "connection" and sw1p3 is the
>>>> switch part (port representation).
>>>>
>>>
>>>
>>> Florian - I am sure you explained this before; I just dont remember. Why
>>> is there need to expose eth0? It seems to me sw1p0-3 are abstracted
>>> already in the kernel and the "cpu port" is merely a control interface.
>>
>>eth0 corresponds to a CPU Ethernet MAC facing e.g: sw1p3 switch port.
>>It is "regular" Ethernet driver connected to the switch without
>>switch-specific logic. The goal is twofold:
>>
>>- allow any regular Ethernet driver to be connected to an external
>>switch via e.g: MDIO/MDC or other without specific switch knowledge
>>- represents accurately how the hardware is designed/connected
>>
>>but maybe, we can simplify and have e.g: sw1p3 and eth0 be the same interface...
>
> I believe that hawing both sw1p3 and eth0 is the correct way of
> modelling this. sw1p3 is instance if switch chip driver representing the
> actual port of a switch. eth0 is an instance of some other ordinary NIC
> driver (8139too is my favorite :))
>
> This model allows to draw the exact picture.
> Also, when you add the described possibility to use iplink to build
> vlans, bridges whatever on the switch ports, it makes perfect sense to
> have this model.
>
> Merging sw1p3 and eth0 would cause a loose of information and confusion.
>

CPU switch port and switch fabric itself should be configured in
consistence with host, in first place I mean a set of VLANs. Also it
should be mentioned that some generic knobs such as port rate and
duplex mode are meaningless for CPU switch port and a lot of status
information (rx/tx counters etc.) duplicates statistics of host
interface which is connected to switch port. So there are no reasons
to force user to configure this port manually, and automatic
configuration of CPU switch port without exporting them as netdev
seems as good approach.

-- 
BR,
Sergey
