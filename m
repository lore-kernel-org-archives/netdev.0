From: Sun Paul <paulrbk@gmail.com>
Subject: Re: Supporting 4 way connections in LKSCTP
Date: Tue, 3 Dec 2013 09:31:02 +0800
Message-ID: <CAFXGft+F52p+oaa59=5e5pGfON44N36NA-XMYi5PorzWeybnKw@mail.gmail.com>
References: <CAFXGft+CXk3W8=3w=AuYzqYtYnR8nH4Of9=668tUeT+tugD9-A@mail.gmail.com>
	<5294BC01.7090605@gmail.com>
	<CAFXGftLsKm9a5bmXX4Fe+rnSvYVdBDOyYGwisRP7XMu+ky=DGw@mail.gmail.com>
	<CAFXGftLt1p6XpR2eGsMYKjEbbOHvch-LgcFw1sAXThcA2Rtjyw@mail.gmail.com>
	<20131127124530.GA23369@hmsreliant.think-freely.org>
	<CAFXGftJQV=5Pqs3bhfiS3T1VO1q8jfaMjAUiqm2tDbtSyBCM3A@mail.gmail.com>
	<529C9B50.50002@gmail.com>
	<CAGugRbXFirQ5P3ek9zN86h4vvO6qsy3eNEooJOApotA+dL+C_g@mail.gmail.com>
	<529CB859.9090904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Karl Heiss <kheiss@gmail.com>, Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:55565 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112Ab3LCBbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 20:31:04 -0500
In-Reply-To: <529CB859.9090904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Vlad

I checked on the route, and it looks correct.

[root@localhost ~]# ip route get 11.1.1.1 from 110.1.1.1
11.1.1.1 from 110.1.1.1 via 110.1.1.254 dev eth1
    cache  mtu 1500 advmss 1460 hoplimit 64

[root@localhost ~]# ip route get 11.1.1.1 from 120.1.1.1
11.1.1.1 from 120.1.1.1 via 120.1.1.254 dev eth2
    cache  mtu 1500 advmss 1460 hoplimit 64

[root@localhost ~]# ip route get 12.1.1.1 from 120.1.1.1
12.1.1.1 from 120.1.1.1 via 120.1.1.254 dev eth2
    cache  mtu 1500 advmss 1460 hoplimit 64

[root@localhost ~]# ip route get 12.1.1.1 from 110.1.1.1
12.1.1.1 from 110.1.1.1 via 110.1.1.254 dev eth1
    cache  mtu 1500 advmss 1460 hoplimit 64

so, if this is not being handled in LKSCTP, is it possible to suggest
a way how we can achieve it?

On Tue, Dec 3, 2013 at 12:42 AM, Vlad Yasevich <vyasevich@gmail.com> wrote:
> On 12/02/2013 10:45 AM, Karl Heiss wrote:
>> On Mon, Dec 2, 2013 at 9:38 AM, Vlad Yasevich <vyasevich@gmail.com> wrote:
>>> On 11/27/2013 11:03 PM, Sun Paul wrote:
>>>> How LKSCTP select which source address to use for the INIT_ACK or
>>>> HB_ACK? below is the testing result where a router is located in the
>>>> middle.
>>>>
>>>> Before starting the application. the packet on eth1 and eth2 are
>>>>
>>>> eth1
>>>> 0 packets dropped by kernel
>>>> [root@localhost ~]# tcpdump -i eth1 -s 0 -nn
>>>> tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
>>>> listening on eth1, link-type EN10MB (Ethernet), capture size 65535 bytes
>>>> 11:24:14.262489 IP 12.1.1.1.2905 > 110.1.1.1.2905: sctp (1) [INIT]
>>>> [init tag: 28362903] [rwnd: 102400] [OS: 16] [MIS: 16] [init TSN: 0]
>>>> 11:24:14.262522 IP 110.1.1.1.2905 > 12.1.1.1.2905: sctp (1) [ABORT]
>>>> 11:24:14.539486
>>>> 11:24:16.262488 IP 12.1.1.1.2905 > 110.1.1.1.2905: sctp (1) [INIT]
>>>> [init tag: 29391734] [rwnd: 102400] [OS: 16] [MIS: 16] [init TSN: 0]
>>>> 11:24:16.262520 IP 110.1.1.1.2905 > 12.1.1.1.2905: sctp (1) [ABORT]
>>>>
>>>> eth2
>>>> [root@localhost ~]# tcpdump -i eth2 -s 0 -nn
>>>> tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
>>>> listening on eth2, link-type EN10MB (Ethernet), capture size 65535 bytes
>>>>
>>>> When starting the application. the packet show as below.
>>>>
>>>> eth1
>>>> 11:26:02.261511 IP 12.1.1.1.2905 > 110.1.1.1.2905: sctp (1) [INIT]
>>>> [init tag: 26256828] [rwnd: 102400] [OS: 16] [MIS: 16] [init TSN: 0]
>>>> 11:26:02.263513 IP 12.1.1.1.2905 > 110.1.1.1.2905: sctp (1) [COOKIE ECHO]
>>>> 11:26:02.264518 IP 12.1.1.1.2905 > 110.1.1.1.2905: sctp (1) [HB REQ]
>>>> 11:26:02.563511 IP 12.1.1.1.2905 > 110.1.1.1.2905: sctp (1) [HB REQ]
>>>>
>>>> eth2
>>>> 11:26:02.261604 IP 120.1.1.1.2905 > 12.1.1.1.2905: sctp (1) [INIT ACK]
>>>> [init tag: 3478239387] [rwnd: 131072] [OS: 5] [MIS: 5] [init TSN:
>>>> 2330749678]
>>>> 11:26:02.263583 IP 120.1.1.1.2905 > 12.1.1.1.2905: sctp (1) [COOKIE ACK]
>>>> 11:26:02.264548 IP 120.1.1.1.2905 > 12.1.1.1.2905: sctp (1) [HB ACK]
>>>> 11:26:02.264652 IP 11.1.1.1.2905 > 120.1.1.1.2905: sctp (1) [HB REQ]
>>>> 11:26:02.264705 IP 120.1.1.1.2905 > 11.1.1.1.2905: sctp (1) [HB ACK]
>>>> 11:26:02.563543 IP 120.1.1.1.2905 > 12.1.1.1.2905: sctp (1) [HB ACK]
>>>>
>>>> From the above result, you can see that the INIT, COOKIE ECHO and
>>>> HB_REQ originated from 12.1.1.1 on eth1, but the ACK (INIT_ACK,
>>>> COOKIE_ACK, HB_ACK) are returned on eth2 using source address
>>>> 120.1.1.1 instead of 110.1.1.1.
>>>>
>>>> Why LKSCTP use 120.1.1.1 as source instead of 110.1.1.1?
>>>>
>>>> For simple ICMP ping test, it is normal, but not for SCTP.
>>>>
>>>> eth1
>>>> 11:30:02.824548 IP 12.1.1.1 > 110.1.1.1: ICMP echo request, id 37178,
>>>> seq 12, length 64
>>>> 11:30:02.824559 IP 110.1.1.1 > 12.1.1.1: ICMP echo reply, id 37178,
>>>> seq 12, length 64
>>>> 11:30:03.825551 IP 12.1.1.1 > 110.1.1.1: ICMP echo request, id 37178,
>>>> seq 13, length 64
>>>> 11:30:03.825561 IP 110.1.1.1 > 12.1.1.1: ICMP echo reply, id 37178,
>>>> seq 13, length 64
>>>>
>>>> eth2
>>>> 11:30:34.027687 IP 11.1.1.1 > 120.1.1.1: ICMP echo request, id 46138,
>>>> seq 2, length 64
>>>> 11:30:34.027697 IP 120.1.1.1 > 11.1.1.1: ICMP echo reply, id 46138,
>>>> seq 2, length 64
>>>> 11:30:35.027686 IP 11.1.1.1 > 120.1.1.1: ICMP echo request, id 46138,
>>>> seq 3, length 64
>>>> 11:30:35.027694 IP 120.1.1.1 > 11.1.1.1: ICMP echo reply, id 46138,
>>>> seq 3, length 64
>>>>
>>>> Below is the route information
>>>> #route -n
>>>> Kernel IP routing table
>>>> Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
>>>> 110.1.1.0       0.0.0.0         255.255.255.0   U     0      0        0 eth1
>>>> 120.1.1.0       0.0.0.0         255.255.255.0   U     0      0        0 eth2
>>>>
>>>> # ip route show
>>>> 110.1.1.0/24 dev eth1  proto kernel  scope link  src 110.1.1.1
>>>> 120.1.1.0/24 dev eth2  proto kernel  scope link  src 120.1.1.1
>>>>
>>>> Since we are using iproute2, so we will have dedicate routing table
>>>> per interface
>>>>
>>>> # ip route show table SCTP1
>>>> default via 110.1.1.254 dev eth1
>>>>
>>>> # ip route show table SCTP2
>>>> default via 120.1.1.254 dev eth2
>>>>
>>>> # ip rule ls
>>>> 0: from all lookup local
>>>> 101: from 110.1.1.1 lookup SCTP1
>>>> 102: from 120.1.1.1 lookup SCTP2
>>>> 32766: from all lookup main
>>>> 32767: from all lookup default
>>>>
>>>> How LKSCTP select source address to reply? If we know how it works,
>>>> then we may know what is going wrong.
>>>
>>> LKSCTP will prefer the address returned from the routing table as long
>>> as it is one of the addresses that is bound by the socket and are usable
>>> by the association.
>>>
>>> If the address returned from the route lookup is not part of the
>>> association, then lksctp attempts to lookup routes using one of the
>>> source addresses it has available.  Usually the first lookup succeeds
>>> due to the host-model implementation in linux.
>>>
>>> You may want to change your rule set to be destination based.  Then
>>> in the table associated with the rule, specify the source address
>>> you want to be used.
>>>
>>> -vlad
>>
>> I have had similar qualms myself about this behavior, and I honestly
>> don't know what the correct answer should be...
>>
>> In my opinion, shouldn't the source address "just work" for
>> acknowledgements? If the spec explicitly states that the ACK should
>> have a source address that matches the destination of the chunk being
>> ACKed, why should someone have to configure this behavior outside of
>> the SCTP stack by default? Is it a technical limitation, or is this
>> done for a particular reason?  I can understand needing to override
>> the behavior, but why isn't the default "sane"?
>
> I think the results are sane, they simply may not match expectations.
> SCTP spec doesn't say anything about source address selection.  It
> says that a response should be send back to the source of the request.
> This is being done in both cases, i.e. the destination address in
> INIT-ACK matches the source of the INIT.
>
> The spec does contain the MAY text that allows finer control of source
> addresses, but lksctp doesn't seem to implement that.  Whenever we've
> tried, we couldn't get the generic mechanism working to please everyone,
> as everyone had slightly different configurations and expectations.  So
> we left it to the rules engine.
>
> In this setup, it just appears that the default routing is not what you
> expect.  You can easily check this with 'ip route get' command.  If it
> is not what you want linux allows you to change that via ip rules.
>
> -vlad
>
>>
>> Karl
>>
>>>>
>>>> On Wed, Nov 27, 2013 at 8:45 PM, Neil Horman <nhorman@tuxdriver.com> wrote:
>>>>> On Wed, Nov 27, 2013 at 07:10:49AM +0800, Sun Paul wrote:
>>>>>> Hi Vlad
>>>>>>
>>>>>> Thank for your reply. If it is based on the destination IP to find the
>>>>>> best route, why the problem didn't happen on single-homing sample?
>>>>>>
>>>>> Because You only ever use one address from NODE A (12.1.1.1)
>>>>>
>>>>>> In the single-homing sample that provided in the original email, both
>>>>>> of the interfaces (eth1 and eth2) are presented on NODE-B during the
>>>>>> test. However, the LKSCTP library know to use the interface eth1 to
>>>>>> respond to the SCTP request.
>>>>>>
>>>>> Yes, because it does a route lookup to each of the two ip addresses to NODE B,
>>>>> and in both lookups, the route indicates that only one source address should be
>>>>> used (12.1.1.1).  If you issue a ip route show command, you'll see that routes
>>>>> to both address on NODE B match on a rule that specifies the same src address
>>>>> and interface be used.
>>>>>
>>>>> Neil
>>>>>
>>>>>> - PS
>>>>>>
>>>>>> On Wed, Nov 27, 2013 at 7:09 AM, Sun Paul <paulrbk@gmail.com> wrote:
>>>>>>> Hi Vlad
>>>>>>>
>>>>>>> Thank for your reply. If it is based on the destination IP to find the
>>>>>>> best route, why the problem didn't happen on single-homing sample?
>>>>>>>
>>>>>>> In the single-homing sample that provided in the original email, both
>>>>>>> of the interfaces (eth1 and eth2) are presented on NODE-B during the
>>>>>>> test. However, the LKSCTP library know to use the interface eth1 to
>>>>>>> respond to the SCTP request.
>>>>>>>
>>>>>>> - PS
>>>>>>>
>>>>>>> On Tue, Nov 26, 2013 at 11:19 PM, Vlad Yasevich <vyasevich@gmail.com> wrote:
>>>>>>>> On 11/25/2013 08:03 PM, Sun Paul wrote:
>>>>>>>>> Hi
>>>>>>>>>
>>>>>>>>> we have a problem on using LKSCTP to form a 4 ways multi-homing network.
>>>>>>>>>
>>>>>>>>> Configuration
>>>>>>>>> - Node-A has 2 IP addresses in different subnets, known as IP-A (eth1),
>>>>>>>>> IP-B (eth2)
>>>>>>>>> - Node-B has 2 IP addresses in different subnets, known as IP-X (eth1),
>>>>>>>>> IP-Y (eth2)
>>>>>>>>>
>>>>>>>>
>>>>>>>> First of all, this is not a 4 way multi-homed network.  As far as each
>>>>>>>> SCTP association is concerned, it has only 2 destinations to send to
>>>>>>>> so it has only 2 ways to get there.  The fact that you have multiple
>>>>>>>> local addresses doesn't mean that every local address can and should
>>>>>>>> be used to connect to the remote.
>>>>>>>>
>>>>>>>>> the four way paths are shown below.
>>>>>>>>> 1. IP-A (11.1.1.1) to IP-X (11.1.1.11)
>>>>>>>>> 2. IP-B (12.1.1.1) to IP-Y (12.1.1.11)
>>>>>>>>> 3. IP-A (11.1.1.1) to IP-Y (12.1.1.11)
>>>>>>>>> 4. IP-B (12.1.1.1) to IP-X (11.1.1.11)
>>>>>>>>
>>>>>>>> No, actually you only have 2 paths:  one to IPX and one to IP-Y.
>>>>>>>> Which source address you choose is based on routing policy
>>>>>>>> decisions and is outside the scope of SCTP.
>>>>>>>>
>>>>>>>>>
>>>>>>>>> the HB/HB_ACK is normal for the paths " IP-A to IP-X" and "IP-B to
>>>>>>>>> IP-Y", but it is not correct for the rest of two.
>>>>>>>>
>>>>>>>> Right, because linux is using a host addressing model, not an interface
>>>>>>>> addressing model.  SCTP stack simply finds the best source address
>>>>>>>> that can be used to reach IP-X and it happens to be IP-A.  So that
>>>>>>>> is what it is going to use.
>>>>>>>>
>>>>>>>> The above explains why you are seeing what you describe below.
>>>>>>>>
>>>>>>>> In the end, linux SCTP implementation determines paths solely based
>>>>>>>> on the destination address.
>>>>>>>>
>>>>>>>> -vlad
>>>>>>>>
>>>>>>>>>
>>>>>>>>> First of all, we are using iproute2 to form 2 table such that when
>>>>>>>>> IP-B arrives on IP-X, it will know how to route back to IP-B on the
>>>>>>>>> same interface, i.e (eth1). Same logic for the path "IP-A to IP-X".
>>>>>>>>>
>>>>>>>>> What we observed here is that when 12.1.1.1 sends INIT to 11.1.1.11,
>>>>>>>>> LKSCTP will send back the INIT_ACK to 12.1.1.1 using 12.1.1.11 but not
>>>>>>>>> using the IP 11.1.1.11.
>>>>>>>>>
>>>>>>>>> The above operation makes the subsequence HB/HB_ACK in using wrong IP address.
>>>>>>>>>
>>>>>>>>> TCP trace on eth1
>>>>>>>>> 18:02:41.058640 IP 12.1.1.1.2905 > 11.1.1.11.2905: sctp (1) [INIT]
>>>>>>>>> [init tag: 19933036] [rwnd: 102400] [OS: 16] [MIS: 16] [init TSN: 0]
>>>>>>>>> 18:02:41.061634 IP 12.1.1.1.2905 > 11.1.1.11.2905: sctp (1) [COOKIE ECHO]
>>>>>>>>> 18:02:41.062642 IP 12.1.1.1.2905 > 11.1.1.11.2905: sctp (1) [HB REQ]
>>>>>>>>> 18:02:41.062846 IP 11.1.1.11.2905 > 11.1.1.1.2905: sctp (1) [HB ACK]
>>>>>>>>> 18:02:41.361811 IP 11.1.1.11.2905 > 11.1.1.1.2905: sctp (1) [HB ACK]
>>>>>>>>> 18:02:41.661791 IP 11.1.1.11.2905 > 11.1.1.1.2905: sctp (1) [HB ACK]
>>>>>>>>> 18:02:41.961791 IP 11.1.1.11.2905 > 11.1.1.1.2905: sctp (1) [HB ACK]
>>>>>>>>>
>>>>>>>>> TCP trace on eth2
>>>>>>>>> 18:02:41.058755 IP 12.1.1.11.2905 > 12.1.1.1.2905: sctp (1) [INIT ACK]
>>>>>>>>> [init tag: 424726157] [rwnd: 131072] [OS: 5] [MIS: 5] [init TSN:
>>>>>>>>> 3340756356]
>>>>>>>>> 18:02:41.061696 IP 12.1.1.11.2905 > 12.1.1.1.2905: sctp (1) [COOKIE ACK]
>>>>>>>>> 18:02:41.062663 IP 12.1.1.11.2905 > 12.1.1.1.2905: sctp (1) [HB ACK]
>>>>>>>>> 18:02:41.062791 IP 11.1.1.1.2905 > 12.1.1.11.2905: sctp (1) [HB REQ]
>>>>>>>>> 18:02:41.361777 IP 11.1.1.1.2905 > 12.1.1.11.2905: sctp (1) [HB REQ]
>>>>>>>>> 18:02:41.661772 IP 11.1.1.1.2905 > 12.1.1.11.2905: sctp (1) [HB REQ]
>>>>>>>>> 18:02:41.961772 IP 11.1.1.1.2905 > 12.1.1.11.2905: sctp (1) [HB REQ]
>>>>>>>>> 18:02:42.161771 IP 11.1.1.1.2905 > 12.1.1.11.2905: sctp (1) [HB REQ]
>>>>>>>>> 18:02:42.461770 IP 11.1.1.1.2905 > 12.1.1.11.2905: sctp (1) [HB REQ]
>>>>>>>>> 18:02:42.675770 IP 11.1.1.1.2905 > 12.1.1.11.2905: sctp (1) [HB REQ]
>>>>>>>>>
>>>>>>>>>
>>>>>>>>> If we are using single homing, there is no problem on the SCTP
>>>>>>>>> communication. Below is the TCP trace on eth1 using sctp_test
>>>>>>>>>
>>>>>>>>> 18:09:55.356727 IP 12.1.1.1.2905 > 11.1.1.11.2905: sctp (1) [INIT]
>>>>>>>>> [init tag: 32516609] [rwnd: 102400] [OS: 16] [MIS: 16] [init TSN: 0]
>>>>>>>>> 18:09:55.356811 IP 11.1.1.11.2905 > 12.1.1.1.2905: sctp (1) [INIT ACK]
>>>>>>>>> [init tag: 3168861995] [rwnd: 131072] [OS: 10] [MIS: 16] [init TSN:
>>>>>>>>> 1877695021]
>>>>>>>>> 18:09:55.357727 IP 12.1.1.1.2905 > 11.1.1.11.2905: sctp (1) [COOKIE ECHO]
>>>>>>>>> 18:09:55.357788 IP 11.1.1.11.2905 > 12.1.1.1.2905: sctp (1) [COOKIE ACK]
>>>>>>>>> 18:09:55.358724 IP 12.1.1.1.2905 > 11.1.1.11.2905: sctp (1) [HB REQ]
>>>>>>>>> 18:09:55.358740 IP 11.1.1.11.2905 > 12.1.1.1.2905: sctp (1) [HB ACK]
>>>>>>>>> 18:09:55.379715 IP 12.1.1.1.2905 > 11.1.1.11.2905: sctp (1) [DATA]
>>>>>>>>> (B)(E) [TSN: 0] [SID: 0] [SSEQ 0] [PPID 0x3]
>>>>>>>>> 18:09:55.379735 IP 11.1.1.11.2905 > 12.1.1.1.2905: sctp (1) [SACK]
>>>>>>>>> [cum ack 0] [a_rwnd 131064] [#gap acks 0] [#dup tsns 0]
>>>>>>>>> 18:09:55.657716 IP 12.1.1.1.2905 > 11.1.1.11.2905: sctp (1) [HB REQ]
>>>>>>>>> 18:09:55.657732 IP 11.1.1.11.2905 > 12.1.1.1.2905: sctp (1) [HB ACK]
>>>>>>>>>
>>>>>>>>> From the observations, it seems that the LKSCTP library is not able to
>>>>>>>>> use the original local address when multi-homing is being used. Is
>>>>>>>>> there anyway can be resolved it?
>>>>>>>>>
>>>>>>>>> Thanks
>>>>>>>>>
>>>>>>>>> PS
>>>>>>>>> --
>>>>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
>>>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>>>>>
>>>>>>>>
>>>>>> --
>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
