From: Vladislav Bolkhovitin <vst@vlnb.net>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Thu, 14 Aug 2008 22:24:11 +0400
Message-ID: <48A4784B.7030500@vlnb.net>
References: <adad4kfxm9v.fsf@cisco.com> <200808121457.11356.divy@chelsio.com> <20080812.150246.42068558.davem@davemloft.net> <200808121521.10101.divy@chelsio.com> <48A32976.7060504@vlnb.net> <48A33633.20800@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, open-iscsi@googlegroups.com,
	rdreier@cisco.com, rick.jones2@hp.com,
	Steve Wise <swise@opengridcomputing.com>,
	Karen Xie <kxie@chelsio.com>, netdev@vger.kernel.org,
	michaelc@cs.wisc.edu, daisyc@us.ibm.com, wenxiong@us.ibm.com,
	bhua@us.ibm.com, Dimitrios Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-relay-04.mailcluster.net ([77.221.130.216]:48639 "EHLO
	mail-relay-02.mailcluster.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752105AbYHNSYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 14:24:07 -0400
In-Reply-To: <48A33633.20800@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Vladislav Bolkhovitin wrote:
>> Divy Le Ray wrote:
>>> On Tuesday 12 August 2008 03:02:46 pm David Miller wrote:
>>>> From: Divy Le Ray <divy@chelsio.com>
>>>> Date: Tue, 12 Aug 2008 14:57:09 -0700
>>>>
>>>>> In any case, such a stateless solution is not yet designed, whereas
>>>>> accelerated iSCSI is available now, from us and other companies.
>>>> So, WHAT?!
>>>>
>>>> There are TOE pieces of crap out there too.
>>> Well, there is demand for accerated iscsi out there, which is the 
>>> driving reason of our driver submission. 
>> I'm, as an iSCSI target developer, strongly voting for hardware iSCSI 
>> offload. Having possibility of the direct data placement is a *HUGE* 
>> performance gain.
> 
> Well, two responses here:
> 
> * no one is arguing against hardware iSCSI offload.  Rather, it is a 
> problem with a specific implementation, one that falsely assumes two 
> independent TCP stacks can co-exist peacefully on the same IP address 
> and MAC.
> 
> * direct data placement is possible without offloading the entire TCP 
> stack onto a firmware/chip.
> 
> There is plenty of room for hardware iSCSI offload...

Sure, nobody is arguing against that. My points are:

1. All those are things not for near future. I don't think it can be 
implemented earlier than in a year time, but there is a huge demand for 
high speed and low CPU overhead iSCSI _now_. Nobody's satisfied by the 
fact that with the latest high end hardware he can saturate 10GbE link 
on only less than 50%(!). Additionally, for me, as an iSCSI target 
developer, it looks especially annoying that hardware requirements for 
_clients_ (initiators) are significantly higher than for _server_ 
(target). This situation for me looks as a nonsense.

2. I believe, that iSCSI/TCP pair is sufficiently heavy weighted 
protocol to be completely offloaded to hardware. All partial offloads 
will never make it comparably efficient. It still would consume a lot of 
CPU. For example, consider digests. Even if they computed by new CRC32C 
instruction, the computation still would need a chunk of CPU power. I 
think, at least as much as to copy the computed block to new location. 
Can we save it? Sure, with hardware offload. The additional CPU load can 
be acceptable if only data are transferred and there are no other 
activities, but in real life this is quite rare. Consider, for instance, 
a VPS server, like VMware. It always lacks CPU power and 30% CPU load 
during data transfers makes a huge difference. Another example is a 
target doing some processing of transferred data, like encryption or 
de-duplication.

Note, I'm not advocating this particular cxgb3 driver. I have not 
examined it closely enough and don't have sufficient knowledge about the 
hardware to judge it. But I'm advocating the concept of full offload 
HBAs, because they provide a real gain, which IMHO can't be reached by 
any partial offloads.

Actually, in the Fibre Channel world from the very beginning the entire 
FC protocol has been implemented on hardware and everybody have been 
happy with that. Now FCoE is coming, which means that Linux kernel is 
going to have implemented in software a big chunk of FC protocol. Then, 
hopefully, nobody would declare all existing FC cards as a crap and 
force FC vendors redesign their hardware to use Linux FC implementation 
and make partial offloads for it? ;) Instead, several implementations 
would live in a peace. The situation is the same with iSCSI. What we 
need is only to find an acceptable way for two TCP implementations to 
coexist. Then iSCSI on 10GbE hardware would have good chances to 
outperform 8Gbps FC in both performance and CPU efficiency.

Vlad

