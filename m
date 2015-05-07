From: Andy Zhou <azhou@nicira.com>
Subject: Re: [net-next fragmenation icmp v2 1/2] bridge_netfilter: No ICMP
 packet on IPv4 defragmentation timeout
Date: Thu, 7 May 2015 13:09:06 -0700
Message-ID: <CACzMAJ+qG0AuWnKDSsRtmq1L2AWoHxvwnDXa6qozMUFdLkrpxg@mail.gmail.com>
References: <1430962033-16141-1-git-send-email-azhou@nicira.com>
	<1430962033-16141-2-git-send-email-azhou@nicira.com>
	<20150507020719.GG21713@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog123.obsmtp.com ([74.125.149.149]:38757 "HELO
	na3sys009aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751365AbbEGUJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 16:09:07 -0400
Received: by mail-ob0-f180.google.com with SMTP id e9so40264204obf.1
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 13:09:06 -0700 (PDT)
In-Reply-To: <20150507020719.GG21713@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 6, 2015 at 7:07 PM, Florian Westphal <fw@strlen.de> wrote:
> Andy Zhou <azhou@nicira.com> wrote:
>> Currently, on defragmentation timeout error, ICMP error message
>> will be generated. This is fine when they are used in a routing context,
>> but does not make sense in the context of bridging netfilter.
>>
>> This patch adds a bit (IPSKB_NO_FRAG_ICMP) in IPCB to control
>> whether ICMP error message should be generated. br_netfiler sets
>> this bit.
>
> Why not use qp->user to make this decision for bridge too?
>
O.K. Will do

>> diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
>> index cc1da6d..447d9ec 100644
>> --- a/net/ipv4/ip_fragment.c
>> +++ b/net/ipv4/ip_fragment.c
>> @@ -217,7 +217,8 @@ static void ip_expire(unsigned long arg)
>>               /* Only an end host needs to send an ICMP
>>                * "Fragment Reassembly Timeout" message, per RFC792.
>>                */
>> -             if (qp->user == IP_DEFRAG_AF_PACKET ||
>>                   ((qp->user >= IP_DEFRAG_CONNTRACK_IN) &&
>>                    (qp->user <= __IP_DEFRAG_CONNTRACK_IN_END) ||
>
>                     ((qp->user >= IP_DEFRAG_CONNTRACK_BRIDGE_IN) &&
>                      (qp->user <= __IP_DEFRAG_CONNTRACK_BRIDGE_IN) &&
>
>
> [ This if cascade is getting silly, might make sense to add
>  'static bool should_send_icmp(enum ip_defrag_users users)', move if
>  tests there and then just
>
> if (should_send_icmp(qp->user) && skb_rtable( ...)

Good idea, will do.
