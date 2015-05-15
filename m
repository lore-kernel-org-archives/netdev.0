From: Andy Zhou <azhou@nicira.com>
Subject: Re: [net-next fragmentation icmp v4 3/4] bridge_netfilter: No ICMP
 packet on IPv4 defragmentation timeout
Date: Thu, 14 May 2015 21:21:20 -0700
Message-ID: <CACzMAJ+tr5scCOqSYFVRFhpAbHKSp21bzTDHdx8JSLzMLQS+ug@mail.gmail.com>
References: <1431570482-9236-4-git-send-email-azhou@nicira.com>
	<20150514085940.GD6179@breakpoint.cc>
	<CACzMAJ+J3QGFZa976_M=_ZKjgEPiJszyYrqeqeGj=9rjCBZJ7A@mail.gmail.com>
	<20150514.174249.797773651224323358.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:54141 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750953AbbEOEVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 00:21:22 -0400
Received: by qcbgy10 with SMTP id gy10so51072086qcb.3
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 21:21:20 -0700 (PDT)
In-Reply-To: <20150514.174249.797773651224323358.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

O.K. I will drop this patch in the next Rev.

On Thu, May 14, 2015 at 2:42 PM, David Miller <davem@davemloft.net> wrote:
> From: Andy Zhou <azhou@nicira.com>
> Date: Thu, 14 May 2015 12:54:23 -0700
>
>> On Thu, May 14, 2015 at 1:59 AM, Florian Westphal <fw@strlen.de> wrote:
>>> Andy Zhou <azhou@nicira.com> wrote:
>>>> Currently, on defragmentation timeout error, ICMP error message
>>>> will be generated. This is fine when they are used in a routing context,
>>>> but does not make sense in the context of bridging netfilter.
>>>>
>>>> This patch adds a bit (IPSKB_NO_FRAG_ICMP) in IPCB to control
>>>> whether ICMP error message should be generated. br_netfiler sets
>>>> this bit.
>>>
>>> Could you please explain why we need this patch?
>>> After the previous change (patch 2 in your series), we will already
>>> bail out before hitting
>>>
>>> /* Send an ICMP "Fragment Reassembly Timeout" message. */
>>> icmp_send(head, ICMP_TIME_EXCEEDED, ICMP_EXC_FRAGTIME, 0);
>>>
>>> in ip_expire() based on qp->user value test?
>>
>> Letting caller making the decision seems to be a better design choice
>> rather than implicit
>> logic embedded within the function.  It is also more flexible and
>> robust when we need to extend 'user'
>> range down the road.
>
> You're doing useless testing for a hypothetical situation which may
> never come to fruitation at all.
>
> I don't think that ever qualifies as a legitimate objection.
