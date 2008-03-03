From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [Devel] Re: network namespace ipv6 perfs
Date: Mon, 03 Mar 2008 18:27:50 +0100
Message-ID: <47CC3516.7030901@bull.net>
References: <47CC0920.6000005@fr.ibm.com> <47CC0E3B.1040809@bull.net>	 <47CC114F.8050104@openvz.org> <939d53060803030704g5d693c19i34061f1a896d91cd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Denis Lunev <den@openvz.org>
To: Benjamin Thery <ben.thery@gmail.com>,
	Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:50181 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762220AbYCCR1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 12:27:40 -0500
In-Reply-To: <939d53060803030704g5d693c19i34061f1a896d91cd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Thery wrote:
> On Mon, Mar 3, 2008 at 3:55 PM, Pavel Emelyanov <xemul@openvz.org> wrote:
>> Benjamin Thery wrote:
>>  > Daniel Lezcano wrote:
>>  >> Hi,
>>  >>
>>  >> Some performance tests was made by Benjamin to watch out the impact of
>>  >> the network namespace. The good news is there is no impact when used
>>  >> with or without namespaces. That has been checked using a real network
>>  >> device inside a network namespace.
>>  >>
>>  >> These results are consistent with the ones previously made for ipv4.
>>  >>
>>  >> http://lxc.sourceforge.net/network/bench_ipv6_graph.php
>>  >>
>>  >> Thanks to Benjamin who did all the performance tests :)
>>  >
>>  > In these results, may be, there is one thing that should be explained.
>>  > It is the CPU utilization overhead in the 'veth' case.
>>  >
>>  > Compared to physical devices or macvlan, veth interfaces don't benefit
>>  > from hardware offloading mechanisms: i.e. checksums have to be computed
>>  > by the soft. That explains the big overhead in CPU utilization when
>>
>>  You can tune the veth devices not to account checksum when unnecessary.
> 
> Oh. This is interesting.
> 
> You mean with ethtool -K rx/tx?
> I will give it a try.

Pavel,

I had no luck with "ethtool -K veth0 rx on tx on".
On my testbed, with these options TCP drops packets
(trying to establish a ssh connection between init and child namespace).


Then, I tested "ethtool -K veth0 rx on tx off".
This time TCP (and netperf) work, but I see no difference in
CPU load compared to the case without offloading.

Can I tune veth differently?

(BTW, I run netperf between a child namespace on host A and netserv
on host B. The stream goes through the following interface:
veth1 on A -> veth0 on A -> eth1 on A -> ("real network") -> eth1 on B)

Benjamin

> 
>>
>>  > using this kind of virtual interface.
>>  >
>>  > Benjamin
>>  >
>>  >> Regards
>>  >>     -- Daniel
>>  >>
> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>  the body of a message to majordomo@vger.kernel.org
>>  More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
