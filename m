From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [Devel] Re: network namespace ipv6 perfs
Date: Wed, 05 Mar 2008 15:39:02 +0300
Message-ID: <47CE9466.90101@openvz.org>
References: <47CC0920.6000005@fr.ibm.com> <47CC0E3B.1040809@bull.net>	 <47CC114F.8050104@openvz.org> <939d53060803030704g5d693c19i34061f1a896d91cd@mail.gmail.com> <47CC3516.7030901@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Benjamin Thery <ben.thery@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Denis Lunev <den@openvz.org>
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:41029 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755518AbYCEMkR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2008 07:40:17 -0500
In-Reply-To: <47CC3516.7030901@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Thery wrote:
> Benjamin Thery wrote:
>> On Mon, Mar 3, 2008 at 3:55 PM, Pavel Emelyanov <xemul@openvz.org> wrote:
>>> Benjamin Thery wrote:
>>>  > Daniel Lezcano wrote:
>>>  >> Hi,
>>>  >>
>>>  >> Some performance tests was made by Benjamin to watch out the impact of
>>>  >> the network namespace. The good news is there is no impact when used
>>>  >> with or without namespaces. That has been checked using a real network
>>>  >> device inside a network namespace.
>>>  >>
>>>  >> These results are consistent with the ones previously made for ipv4.
>>>  >>
>>>  >> http://lxc.sourceforge.net/network/bench_ipv6_graph.php
>>>  >>
>>>  >> Thanks to Benjamin who did all the performance tests :)
>>>  >
>>>  > In these results, may be, there is one thing that should be explained.
>>>  > It is the CPU utilization overhead in the 'veth' case.
>>>  >
>>>  > Compared to physical devices or macvlan, veth interfaces don't benefit
>>>  > from hardware offloading mechanisms: i.e. checksums have to be computed
>>>  > by the soft. That explains the big overhead in CPU utilization when
>>>
>>>  You can tune the veth devices not to account checksum when unnecessary.
>> Oh. This is interesting.
>>
>> You mean with ethtool -K rx/tx?
>> I will give it a try.
> 
> Pavel,
> 
> I had no luck with "ethtool -K veth0 rx on tx on".
> On my testbed, with these options TCP drops packets
> (trying to establish a ssh connection between init and child namespace).
> 
> 
> Then, I tested "ethtool -K veth0 rx on tx off".
> This time TCP (and netperf) work, but I see no difference in
> CPU load compared to the case without offloading.
> 
> Can I tune veth differently?

Yup. You may try turn tso and sg on as well.

> (BTW, I run netperf between a child namespace on host A and netserv
> on host B. The stream goes through the following interface:
> veth1 on A -> veth0 on A -> eth1 on A -> ("real network") -> eth1 on B)
> 
> Benjamin
> 
>>>  > using this kind of virtual interface.
>>>  >
>>>  > Benjamin
>>>  >
>>>  >> Regards
>>>  >>     -- Daniel
>>>  >>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>  the body of a message to majordomo@vger.kernel.org
>>>  More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
> 
> 

