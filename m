From: Ulf samuelsson <netdev@emagii.com>
Subject: Re: [PATCH V2 0/1] neighbour: Support broadcast ARP in neighbor PROPE state
Date: Thu, 12 Mar 2015 09:59:48 +0100
Message-ID: <B35CF589-BE57-4F34-9CC2-A657F3DCF264@emagii.com>
References: <1426143501-30827-1-git-send-email-Yanjun.Zhu@windriver.com> <55013BD4.2080605@windriver.com> <5501518D.2070405@miraclelinux.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: yzhu1 <Yanjun.Zhu@windriver.com>,
	"brian.haley@hp.com" <brian.haley@hp.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"alexandre.dietsch@windriver.com" <alexandre.dietsch@windriver.com>,
	"clinton.slabbert@windriver.com" <clinton.slabbert@windriver.com>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ulf.samuelsson@ericsson.com" <ulf.samuelsson@ericsson.com>,
	"YOSHIFUJI Hideaki (USAGI Project)" <yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out12.han.skanova.net ([195.67.226.212]:41472 "EHLO
	smtp-out12.han.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752470AbbCLJGf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2015 05:06:35 -0400
In-Reply-To: <5501518D.2070405@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That also means that you increase the number of broadcasts in incomplete state.
Is that really desirable?

Best Regards
Ulf Samuelsson
ulf@emagii.com
+46  (722) 427 437


> 12 mar 2015 kl. 09:42 skrev YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>:
> 
> Hello.
> 
> yzhu1 wrote:
>> The state machine is in the attachment.
>> 
>> Best Regards!
>> Zhu Yanjun
>>> On 03/12/2015 02:58 PM, Zhu Yanjun wrote:
>>> V2:
>>>   set ARP_PROBE_BCAST default N.
>>> 
>>> V1:
>>>   Have a problem with an HP router at a certain location, which
>>>   is configured to only answer to broadcast ARP requests.
>>>   That cannot be changed.
>>> 
>>>   The first ARP request the kernel sends out, is a broadcast request,
>>>   which is fine, but after the reply, the kernel sends unicast requests,
>>>   which will not get any replies.
>>> 
>>>   The ARP entry will after some time enter STALE state,
>>>   and if nothing is done it will time out, and be removed.
>>>   This process takes to long, and I have been told that it is
>>>   difficult to makes changes that will eventually remove it.
>>> 
>>>   Have tried to change the state from STALE to INCOMPLETE, which failed,
>>>   and then tried to change the state to PROBE which also failed.
>>> 
>>>   The stack is only sending out unicasts, and never broadcast.
>>>   Is there any way to get the stack to send out a broadcast ARP
>>>   without having to wait for the entry to be removed?
> 
> Neighbour subsystem will send multicast probes after unicast
> probes in NUD_PROBE state if mcast_solicit is more than
> ucast_solicit.  Try setting net.ipv4.neigh.*.ucast_solicit to
> the value less than net.ipv4.neigh.*.mcast_solicit, please?
> e.g.
> 
> net.ipv4.neigh.eth0.mcast_solicit = 3
> net.ipv4.neigh.eth0.ucast_solicit = 1
> 
> --yoshfuji
> 
> 
>>> 
>>>   I think the recommended behaviour in IPv6 is to send out 3 unicasts
>>>   and if all fails, to send out broadcasts.
>>> 
>>> Zhu Yanjun (1):
>>>   neighbour: Support broadcast ARP in neighbor PROPE state
>>> 
>>>  include/net/neighbour.h        |  7 ++++++
>>>  include/uapi/linux/neighbour.h |  6 +++++
>>>  include/uapi/linux/sysctl.h    |  3 +++
>>>  kernel/sysctl_binary.c         |  3 +++
>>>  net/core/neighbour.c           | 44 +++++++++++++++++++++++++++++---
>>>  net/ipv4/Kconfig               | 57 ++++++++++++++++++++++++++++++++++++++++++
>>>  net/ipv4/arp.c                 |  7 ++++--
>>>  7 files changed, 121 insertions(+), 6 deletions(-)
> 
> -- 
> Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
> Technical Division, MIRACLE LINUX CORPORATION
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
