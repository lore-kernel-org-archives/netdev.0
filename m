From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH V2 0/1] neighbour: Support broadcast ARP in neighbor PROPE
 state
Date: Thu, 12 Mar 2015 17:42:53 +0900
Message-ID: <5501518D.2070405@miraclelinux.com>
References: <1426143501-30827-1-git-send-email-Yanjun.Zhu@windriver.com> <55013BD4.2080605@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	"YOSHIFUJI Hideaki (USAGI Project)" <yoshfuji@linux-ipv6.org>
To: yzhu1 <Yanjun.Zhu@windriver.com>, brian.haley@hp.com,
	davem@davemloft.net, alexandre.dietsch@windriver.com,
	clinton.slabbert@windriver.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, kaber@trash.net, netdev@vger.kernel.org,
	ulf.samuelsson@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og124.obsmtp.com ([64.18.2.26]:45196 "HELO
	exprod7og124.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753057AbbCLIm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 04:42:59 -0400
Received: by mail-pd0-f181.google.com with SMTP id fp1so18427984pdb.2
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 01:42:58 -0700 (PDT)
In-Reply-To: <55013BD4.2080605@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

yzhu1 wrote:
> The state machine is in the attachment.
>
> Best Regards!
> Zhu Yanjun
> On 03/12/2015 02:58 PM, Zhu Yanjun wrote:
>> V2:
>>    set ARP_PROBE_BCAST default N.
>>
>> V1:
>>    Have a problem with an HP router at a certain location, which
>>    is configured to only answer to broadcast ARP requests.
>>    That cannot be changed.
>>
>>    The first ARP request the kernel sends out, is a broadcast request,
>>    which is fine, but after the reply, the kernel sends unicast requests,
>>    which will not get any replies.
>>
>>    The ARP entry will after some time enter STALE state,
>>    and if nothing is done it will time out, and be removed.
>>    This process takes to long, and I have been told that it is
>>    difficult to makes changes that will eventually remove it.
>>
>>    Have tried to change the state from STALE to INCOMPLETE, which failed,
>>    and then tried to change the state to PROBE which also failed.
>>
>>    The stack is only sending out unicasts, and never broadcast.
>>    Is there any way to get the stack to send out a broadcast ARP
>>    without having to wait for the entry to be removed?

Neighbour subsystem will send multicast probes after unicast
probes in NUD_PROBE state if mcast_solicit is more than
ucast_solicit.  Try setting net.ipv4.neigh.*.ucast_solicit to
the value less than net.ipv4.neigh.*.mcast_solicit, please?
e.g.

net.ipv4.neigh.eth0.mcast_solicit = 3
net.ipv4.neigh.eth0.ucast_solicit = 1

--yoshfuji


>>
>>    I think the recommended behaviour in IPv6 is to send out 3 unicasts
>>    and if all fails, to send out broadcasts.
>>
>> Zhu Yanjun (1):
>>    neighbour: Support broadcast ARP in neighbor PROPE state
>>
>>   include/net/neighbour.h        |  7 ++++++
>>   include/uapi/linux/neighbour.h |  6 +++++
>>   include/uapi/linux/sysctl.h    |  3 +++
>>   kernel/sysctl_binary.c         |  3 +++
>>   net/core/neighbour.c           | 44 +++++++++++++++++++++++++++++---
>>   net/ipv4/Kconfig               | 57 ++++++++++++++++++++++++++++++++++++++++++
>>   net/ipv4/arp.c                 |  7 ++++--
>>   7 files changed, 121 insertions(+), 6 deletions(-)
>>
>

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
